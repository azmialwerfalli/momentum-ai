# Momentum AI - API Contract v1.0

Base URL: `http://localhost:8000`

---

## Authentication

### 1. Register User
*   **Endpoint:** `POST /auth/register`
*   **Description:** Creates a new user account.
*   **Request Body:**
    ```json
    {
      "email": "user@example.com",
      "password": "strongpassword123",
      "username": "testuser"
    }
    ```
*   **Success Response (201 Created):**
    ```json
    {
      "user_id": "a-uuid-string",
      "email": "user@example.com",
      "username": "testuser"
    }
    ```

### 2. Login User
*   **Endpoint:** `POST /auth/login`
*   **Description:** Authenticates a user and returns an access token.
*   **Request Body:** (Uses OAuth2 standard form data, not JSON)
    *   `username`: "user@example.com" (we'll use email as the username field)
    *   `password`: "strongpassword123"
*   **Success Response (200 OK):**
    ```json
    {
      "access_token": "a-jwt-token-string",
      "token_type": "bearer"
    }
    ```

---

## Goals (Requires Authentication)

### 3. Create a New Goal
*   **Endpoint:** `POST /goals`
*   **Description:** Creates a new high-level goal for the logged-in user.
*   **Request Body:**
    ```json
    {
      "title": "Run a 5K",
      "description": "Get back into running shape.",
      "goal_type": "TARGET_VALUE",
      "target_value": 5,
      "target_unit": "km",
      "target_date": "2025-12-31"
    }
    ```
*   **Success Response (201 Created):** (Returns the created goal)
    ```json
    {
      "goal_id": "a-new-uuid-string",
      "user_id": "the-user-uuid",
      "title": "Run a 5K",
      // ... all other goal fields
    }
    ```

### 4. Get User's Goals
*   **Endpoint:** `GET /goals`
*   **Description:** Retrieves all active goals for the logged-in user.
*   **Success Response (200 OK):**
    ```json
    [
      {
        "goal_id": "a-uuid-string",
        "title": "Run a 5K",
        // ... all other goal fields
      },
      {
        "goal_id": "another-uuid-string",
        "title": "Read 20 books this year",
        // ... all other goal fields
      }
    ]
    ```

---

## Dashboard & Progress (Requires Authentication)

### 5. Get Daily Habits for Dashboard
*   **Endpoint:** `GET /dashboard/{date}` (e.g., `/dashboard/2023-10-27`)
*   **Description:** Retrieves all habits the user needs to perform on a given day, along with their completion status.
*   **Success Response (200 OK):**
    ```json
    [
      {
        "habit_id": "habit-uuid-1",
        "title": "Daily Morning Run",
        "is_completed": true,
        "progress_log_id": "log-uuid-if-completed"
      },
      {
        "habit_id": "habit-uuid-2",
        "title": "Read Quran for 10 minutes",
        "is_completed": false,
        "progress_log_id": null
      }
    ]
    ```

### 6. Log Habit Progress
*   **Endpoint:** `POST /progress-logs`
*   **Description:** Records that a habit has been completed.
*   **Request Body:**
    ```json
    {
      "habit_id": "habit-uuid-2",
      "log_date": "2025-05-27",
      "value_achieved": 1 // 1 for completion, or could be pages read, etc.
    }
    ```
*   **Success Response (201 Created):** (Returns the created log entry)
    ```json
    {
      "log_id": "a-new-log-uuid",
      "habit_id": "habit-uuid-2",
      // ... all other log fields
    }
    ```