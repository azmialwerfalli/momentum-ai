# server/app/coaching_engine.py

# This is our "AI" knowledge base for a beginner's 5K plan.
# It's a structured set of rules.
COUCH_TO_5K_PLAN = {
    1: "Week 1: Brisk 5-min warmup. Then alternate 60 secs jogging and 90 secs walking for 20 mins.",
    2: "Week 2: Brisk 5-min warmup. Then alternate 90 secs jogging and 2 mins walking for 20 mins.",
    3: "Week 3: Brisk 5-min warmup. Then two reps of: 200m jog (or 90 secs), 200m walk (or 90 secs), 400m jog (or 3 mins), 400m walk (or 3 mins).",
    4: "Week 4: Brisk 5-min warmup. Then: 400m jog (3 mins), 200m walk (90 secs), 800m jog (5 mins), 400m walk (2.5 mins), 400m jog (3 mins), 200m walk (90 secs), 800m jog (5 mins).",
    5: "Week 5: Day 1: 800m jog (5 mins), 400m walk (3 mins), 800m jog (5 mins), 400m walk (3 mins), 800m jog (5 mins). Day 2: 1.2km jog (8 mins), 800m walk (5 mins), 1.2km jog (8 mins). Day 3: 3.2km jog (20 mins) with no walking.",
    6: "Week 6: Brisk 5-min warmup. Then: 800m jog (5 mins), 400m walk (3 mins), 1.2km jog (8 mins), 400m walk (3 mins), 800m jog (5 mins).",
    7: "Week 7: Brisk 5-min warmup. Then jog 4km (or 25 mins) with no walking.",
    8: "Week 8: Brisk 5-min warmup. Then jog 4.5km (or 28 mins) with no walking.",
    9: "Week 9: You're ready! Run the full 5K. Focus on a steady pace. You've got this!",
}


def generate_running_plan(current_week: int):
    """
    Generates a running plan for a specific week.
    In a more advanced version, this could also take 'current_fitness_level'.
    """
    if current_week in COUCH_TO_5K_PLAN:
        return {"week": current_week, "plan_details": COUCH_TO_5K_PLAN[current_week]}
    else:
        return {"week": current_week, "plan_details": "Congratulations on finishing the program! Or, invalid week number."}

def get_missed_habit_feedback(habit_title: str, reason: str | None):
    """
    Provides compassionate advice for a missed prayer.
    """
    title_lower = habit_title.lower()

    # Check if it's a spiritual habit
    if 'prayer' in title_lower or 'quran' in title_lower or 'salah' in title_lower:
        if reason == 'asleep':
            return "It's okay, these things happen. The Prophet (PBUH) taught us to perform the prayer as soon as we remember. Let's make the intention to perform the Qada prayer now."
        elif reason == 'busy':
            return "Allah understands our struggles. Take a few moments for your Qada prayer. A short break for prayer can bring great peace."
        else:
            return "Don't be discouraged. The most important thing is to turn back to Allah. Perform your Qada prayer as soon as you are able."
    
    # Otherwise, it's a general/physical/mental habit
    else:
        if reason == 'busy':
            return "Life gets hectic. Don't let one missed session stop you. Can we reschedule for later today, or just focus on being ready for tomorrow?"
        elif reason == 'unmotivated':
            return "Motivation is a wave, it comes and goes. Discipline is what builds the shore. We missed today, but the real win is showing up tomorrow. Let's do it."
        else:
            return "One step back is okay as long as the next step is forward. Acknowledge it, let it go, and prepare for your next success."

# We can add more coaching functions here later...