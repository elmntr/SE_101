// supabase/functions/update-user-email/index.ts
// Edge Function: Update a Supabase Auth user's email
// Called from: SupabaseAuthService.updateAuthUserEmail()
// NOTE: This file uses Deno runtime (not Node.js). VSCode errors are expected.

// @ts-ignore - Deno runtime modules
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
// @ts-ignore - Deno runtime modules
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Global Deno namespace (available in Supabase Edge Functions runtime)
declare const Deno: {
  env: {
    get(key: string): string | undefined
  }
}

// Type definitions
interface RequestBody {
  user_id: string
  new_email: string
}

serve(async (req: Request) => {
  // CORS headers
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  }

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { user_id, new_email } = await req.json() as RequestBody

    if (!user_id || !new_email) {
      return new Response(
        JSON.stringify({ error: 'user_id and new_email are required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Basic email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(new_email)) {
      return new Response(
        JSON.stringify({ error: 'Invalid email format' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Create admin client with service role key
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false,
        },
      }
    )

    // Verify the requesting user is authenticated
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Missing authorization header' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const token = authHeader.replace('Bearer ', '')
    const { data: { user: callingUser }, error: authError } = await supabaseAdmin.auth.getUser(token)
    
    if (authError || !callingUser) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Check if new email already exists
    const { data: existingUsers, error: checkError } = await supabaseAdmin.auth.admin.listUsers()
    if (checkError) {
      return new Response(
        JSON.stringify({ error: 'Failed to check existing emails' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const emailExists = existingUsers.users.some(
      (u: { email: string | undefined; id: string }) => u.email === new_email && u.id !== user_id
    )
    if (emailExists) {
      return new Response(
        JSON.stringify({ error: 'Email already registered' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Update email using admin API (bypasses validation restrictions)
    const { data, error: updateError } = await supabaseAdmin.auth.admin.updateUserById(
      user_id,
      { 
        email: new_email,
        email_confirm: true  // Auto-confirm the new email
      }
    )

    if (updateError) {
      return new Response(
        JSON.stringify({ error: updateError.message }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: 'Email updated successfully',
        new_email: data.user.email
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : 'Unknown error occurred' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
