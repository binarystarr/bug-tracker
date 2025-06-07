import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL
const supabaseAnonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error(
    'Missing Supabase environment variables. Please create a .env file with:\n' +
    'PUBLIC_SUPABASE_URL=your_supabase_project_url\n' +
    'PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key\n\n' +
    'See SETUP.md for detailed instructions.'
  )
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

export type Database = {
  public: {
    Tables: {
      bugs: {
        Row: {
          id: string
          title: string
          description: string | null
          status: 'open' | 'in_progress' | 'resolved' | 'closed'
          priority: 'low' | 'medium' | 'high' | 'critical'
          created_at: string
          updated_at: string
          assigned_to: string | null
          reporter: string | null
        }
        Insert: {
          id?: string
          title: string
          description?: string | null
          status?: 'open' | 'in_progress' | 'resolved' | 'closed'
          priority?: 'low' | 'medium' | 'high' | 'critical'
          created_at?: string
          updated_at?: string
          assigned_to?: string | null
          reporter?: string | null
        }
        Update: {
          id?: string
          title?: string
          description?: string | null
          status?: 'open' | 'in_progress' | 'resolved' | 'closed'
          priority?: 'low' | 'medium' | 'high' | 'critical'
          created_at?: string
          updated_at?: string
          assigned_to?: string | null
          reporter?: string | null
        }
      }
    }
  }
}

export type Bug = Database['public']['Tables']['bugs']['Row'] 