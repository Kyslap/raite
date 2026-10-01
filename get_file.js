const { createClient } = require('@supabase/supabase-js');
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_ANON_KEY
);
async function run() {
  const { data, error } = await supabase.storage.from('class_materials').download('materials/7cfeb75b-b0b6-4de3-b888-bb78b951c90a/1790866267049_03 Elements of Design (Handout).txt');
  if (error) { console.error("Error:", error); }
  else { 
    const text = await data.text();
    console.log("File length:", text.length);
    console.log("File content sample:", JSON.stringify(text.substring(0, 100)));
  }
}
run();
