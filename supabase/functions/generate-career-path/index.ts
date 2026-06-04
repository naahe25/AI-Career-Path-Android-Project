import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface UserContext {
  full_name: string;
  current_skills: string[];
  education_level: string;
  years_of_experience: number;
  user_current_role: string;
  desired_field: string;
}

interface CareerPathStep {
  title: string;
  description: string;
  estimated_weeks: number;
  skills_gained: string[];
  resources: { title: string; url: string; type: string }[];
}

interface GeneratedCareerPath {
  title: string;
  description: string;
  target_role: string;
  estimated_duration_months: number;
  difficulty_level: string;
  milestones: CareerPathStep[];
}

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Extract JWT from Authorization header to identify the user
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "Missing authorization header" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Create Supabase client with the user's JWT
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      {
        global: { headers: { Authorization: authHeader } },
      }
    );

    // Verify user is authenticated
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser();
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: "Unauthorized" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Parse request body
    const userContext: UserContext = await req.json();

    // Validate required fields
    if (!userContext.desired_field) {
      return new Response(
        JSON.stringify({ error: "desired_field is required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Build the prompt for Claude
    const systemPrompt = `You are an expert career counselor and AI advisor. Your job is to generate highly specific, actionable career development paths. You always respond with valid JSON only. No markdown, no explanation outside the JSON structure.`;

    const userPrompt = `Generate 2 distinct career paths for the following person:

Name: ${userContext.full_name || "User"}
Current Skills: ${userContext.current_skills?.join(", ") || "Not specified"}
Education Level: ${userContext.education_level || "Not specified"}
Years of Experience: ${userContext.years_of_experience || 0}
Current Role: ${userContext.user_current_role || "Student/Entry Level"}
Desired Field: ${userContext.desired_field}

Return a JSON object with this exact structure:
{
  "career_paths": [
    {
      "title": "Career Path Title",
      "description": "2-3 sentence overview of this path",
      "target_role": "Final job title to achieve",
      "estimated_duration_months": 12,
      "difficulty_level": "beginner|intermediate|advanced",
      "milestones": [
        {
          "title": "Milestone Title",
          "description": "What to accomplish in this milestone",
          "estimated_weeks": 4,
          "skills_gained": ["skill1", "skill2"],
          "resources": [
            {
              "title": "Resource Name",
              "url": "https://actual-url.com",
              "type": "course|book|documentation|video|project"
            }
          ]
        }
      ]
    }
  ]
}

Each path must have 4 to 6 milestones. Make resources real and specific. Be concrete.`;

    // Call Anthropic Claude API
    const anthropicResponse = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": Deno.env.get("ANTHROPIC_API_KEY") ?? "",
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify({
        model: "claude-sonnet-4-20250514",
        max_tokens: 4096,
        system: systemPrompt,
        messages: [
          {
            role: "user",
            content: userPrompt,
          },
        ],
      }),
    });

    if (!anthropicResponse.ok) {
      const errorText = await anthropicResponse.text();
      console.error("Anthropic API error:", errorText);
      return new Response(
        JSON.stringify({ error: "AI service unavailable. Please try again." }),
        { status: 503, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const anthropicData = await anthropicResponse.json();
    const rawContent = anthropicData.content[0].text;
    const tokensUsed = anthropicData.usage?.input_tokens + anthropicData.usage?.output_tokens;

    // Parse the JSON response from Claude
    let parsedPaths: { career_paths: GeneratedCareerPath[] };
    try {
      parsedPaths = JSON.parse(rawContent);
    } catch {
      // Claude sometimes wraps JSON in markdown, strip it
      const cleanContent = rawContent
        .replace(/```json\n?/g, "")
        .replace(/```\n?/g, "")
        .trim();
      parsedPaths = JSON.parse(cleanContent);
    }

    // Store the recommendation in the database using service role client
    const serviceClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    const { error: insertError } = await serviceClient
      .from("ai_recommendations")
      .insert({
        user_id: user.id,
        prompt_context: userContext,
        raw_response: rawContent,
        parsed_career_paths: parsedPaths,
        model_used: "claude-sonnet-4-20250514",
        tokens_used: tokensUsed,
      });

    if (insertError) {
      console.error("Failed to store recommendation:", insertError);
      // Non-fatal, continue and return the result to user
    }

    return new Response(
      JSON.stringify({
        success: true,
        data: parsedPaths.career_paths,
        recommendation_stored: !insertError,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      }
    );
  } catch (error) {
    console.error("Edge function error:", error);
    return new Response(
      JSON.stringify({ error: "Internal server error", details: error.message }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 500,
      }
    );
  }
});