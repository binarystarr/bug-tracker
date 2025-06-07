# Bug Tracker Setup Guide

This guide will help you set up the Bug Tracker application with Supabase.

## Prerequisites

- Node.js (v18 or later)
- A Supabase account

## 1. Supabase Setup

### Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Wait for the project to initialize
3. Go to Settings → API to find your project URL and anon key

### Database Setup

1. In your Supabase dashboard, go to the SQL Editor
2. Copy and paste the contents of `database-setup.sql` 
3. Run the SQL to create the bugs table and necessary indexes

## 2. Environment Configuration

Create a `.env` file in your project root with the following variables:

```env
PUBLIC_SUPABASE_URL=your_supabase_project_url
PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
```

Replace the values with your actual Supabase project URL and anonymous key from step 1.

## 3. Install Dependencies

```bash
npm install
```

## 4. Run the Development Server

```bash
npm run dev
```

The application should now be running at `http://localhost:4321`

## Features

- ✅ Create new bug reports
- ✅ View all bugs in a card layout
- ✅ Edit existing bugs
- ✅ Update bug status (Open, In Progress, Resolved, Closed)
- ✅ Set bug priority (Low, Medium, High, Critical)
- ✅ Filter bugs by status and priority
- ✅ Search bugs by title and description
- ✅ Delete bugs with confirmation
- ✅ Assign bugs to team members
- ✅ Track reporter information
- ✅ Automatic timestamp tracking

## Database Schema

The `bugs` table includes:
- `id` (UUID, Primary Key)
- `title` (VARCHAR, Required)
- `description` (TEXT, Optional)
- `status` (VARCHAR, Default: 'open')
- `priority` (VARCHAR, Default: 'medium')
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP, Auto-updated)
- `assigned_to` (VARCHAR, Optional)
- `reporter` (VARCHAR, Optional)

## Customization

You can customize the application by:
- Modifying the status and priority options in the components
- Adding additional fields to the bug schema
- Implementing user authentication
- Adding email notifications
- Creating reports and analytics

## Troubleshooting

- Make sure your Supabase URL and keys are correct
- Ensure the database table is created properly
- Check browser console for any JavaScript errors
- Verify that Row Level Security policies allow the operations you're trying to perform 