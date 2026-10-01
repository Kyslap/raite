import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '' // Need admin access to bypass RLS for processing
    )

    const { document_id, class_id } = await req.json()

    if (!document_id || !class_id) {
      throw new Error("Missing document_id or class_id")
    }

    // 1. Fetch document metadata
    const { data: docData, error: docError } = await supabaseClient
      .from('class_documents')
      .select('file_url, raw_text_url')
      .eq('id', document_id)
      .single()

    if (docError || !docData) throw new Error("Document not found: " + docError?.message)

    // Fallback to file_url for backwards compatibility
    const targetUrl = docData.raw_text_url || docData.file_url;

    if (!targetUrl) throw new Error("Document has no target URL to process");

    // 2. Download file from storage
    // file_url looks like "class_materials/filename.pdf" or "class_materials/filename.txt"
    const { data: fileData, error: fileError } = await supabaseClient
      .storage
      .from('class_materials')
      .download(targetUrl)

    if (fileError || !fileData) throw new Error("Failed to download file: " + fileError?.message)

    // 3. Extract text
    let extractedText = "";
    if (targetUrl.endsWith('.txt') || targetUrl.endsWith('.md') || targetUrl.endsWith('.csv')) {
      extractedText = await fileData.text();
    } else {
      throw new Error("Currently only plain text files (.txt, .md, .csv) are supported for the AI Brain.");
    }

    if (!extractedText || extractedText.trim() === '') {
      throw new Error("No text could be extracted from the file.")
    }

    // 4. Basic Text Chunking (split by paragraphs or ~1000 characters)
    // A simple chunker splitting by double newlines or sentences.
    const rawChunks = extractedText.split(/\n\s*\n/).filter(c => c.trim().length > 50);
    const maxChunkSize = 2000;
    const finalChunks: string[] = [];
    
    for (const raw of rawChunks) {
      if (raw.length <= maxChunkSize) {
        finalChunks.push(raw);
      } else {
        // Split further if too large
        let current = "";
        const sentences = raw.split('. ');
        for (const sentence of sentences) {
          if (current.length + sentence.length > maxChunkSize) {
            finalChunks.push(current);
            current = sentence + ". ";
          } else {
            current += sentence + ". ";
          }
        }
        if (current.trim().length > 0) finalChunks.push(current);
      }
    }

    // 5. Generate Embeddings & Insert
    const geminiApiKey = Deno.env.get('GEMINI_API_KEY');
    if (!geminiApiKey) throw new Error("GEMINI_API_KEY secret is missing");

    const chunkInserts = [];

    // Process chunks in batches to avoid rate limits
    for (let i = 0; i < finalChunks.length; i++) {
      const textChunk = finalChunks[i].trim();
      if (!textChunk) continue;

      // Call Gemini Embedding API (gemini-embedding-2)
      const embeddingResponse = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent?key=${geminiApiKey}`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            model: 'models/gemini-embedding-2',
            content: { parts: [{ text: textChunk }] },
            outputDimensionality: 768
          })
        }
      );

      if (!embeddingResponse.ok) {
        const errText = await embeddingResponse.text();
        throw new Error(`Embedding API failed: ${errText}`);
      }

      const embedData = await embeddingResponse.json();
      const embedding = embedData.embedding.values;

      chunkInserts.push({
        document_id,
        class_id,
        content: textChunk,
        embedding: embedding
      });
    }

    // Insert all chunks into the database
    if (chunkInserts.length > 0) {
      const { error: insertError } = await supabaseClient
        .from('document_chunks')
        .insert(chunkInserts);

      if (insertError) throw new Error("Failed to insert chunks: " + insertError.message)
    }

    return new Response(
      JSON.stringify({ success: true, chunksProcessed: chunkInserts.length }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
    )
  }
})
