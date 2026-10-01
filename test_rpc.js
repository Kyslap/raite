const { createClient } = require('@supabase/supabase-js');
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);
async function run() {
  const dummyEmbedding = Array(768).fill(0.1);
  const { data, error } = await supabase.rpc('match_class_documents', {
    query_embedding: dummyEmbedding,
    match_threshold: -1,
    match_count: 3
  });
  console.log('Error:', error);
  console.log('Data:', data?.length);
}
run();
