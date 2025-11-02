// File: supabase/functions/ask-gemini/index.ts (FINAL WORKING CODE WITH SMART OPTIONS HANDLING)

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { corsHeaders } from '../_shared/cors.ts'

const GOOGLE_AI_API_KEY = Deno.env.get('GOOGLE_AI_API_KEY')
const API_URL = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${GOOGLE_AI_API_KEY}`

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }
  try {
    const { userPrompt, conversationHistory, questionText, options, correctAnswer, solution } = await req.json();
    const history = conversationHistory.map((msg: { role: string; content: string }) => ({
      role: msg.role === 'assistant' ? 'model' : 'user',
      parts: [{ text: msg.content }],
    }));

    // 👇 YEH HAI NAYA, SMART CODE 👇
    // Pehle check karo ki 'options' ek object hai ya array.
    // Phir usko ek simple text string mein convert karo.
    let optionsText = '';
    if (Array.isArray(options)) {
      optionsText = options.join(', '); // Agar array hai, to direct join karo
    } else if (typeof options === 'object' && options !== null) {
      optionsText = Object.values(options).join(', '); // Agar object hai, to uski values ko join karo
    }
    // ------------------------------------
    
    const currentPrompt = `
      QUESTION CONTEXT:
      Question: ${questionText}
      Options: ${optionsText} // <-- Hum yahan naya variable use kar rahe hain
      Correct Answer: ${correctAnswer}
      Provided Solution: ${solution}
      MY DOUBT: "${userPrompt}"
    `;
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [...history, { role: 'user', parts: [{ text: currentPrompt }] }],
        safetySettings: [{ category: "HARM_CATEGORY_HARASSMENT", threshold: "BLOCK_MEDIUM_AND_ABOVE" }, { category: "HARM_CATEGORY_HATE_SPEECH", threshold: "BLOCK_MEDIUM_AND_ABOVE" }, { category: "HARM_CATEGORY_SEXUALLY_EXPLICIT", threshold: "BLOCK_MEDIUM_AND_ABOVE" }, { category: "HARM_CATEGORY_DANGEROUS_CONTENT", threshold: "BLOCK_MEDIUM_AND_ABOVE" }],
      }),
    });
    const data = await response.json();
    if (data.error || !data.candidates) { throw new Error(data.error?.message || 'AI response format is incorrect.'); }
    const aiReply = data.candidates[0].content.parts[0].text;
    return new Response(JSON.stringify({ reply: aiReply }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    });
  }
})