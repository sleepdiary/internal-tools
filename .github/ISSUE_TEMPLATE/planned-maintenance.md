---
name: Planned maintenance
about: Tracking ticket for planned maintenance
title: "Planned maintenance: TODO: purpose of this maintenance"
labels: planned-maintenance
assignees: ''

---

This issue tracks a period of planned maintenance.  For example, an update that risks breaking the site for users or causing automated actions to fail.  You should only use this if you maintain the sleepdiary project itself.

## Summary

**Reason for maintenance:** TODO: one line explanation of why this maintenance is required
**Issues to be aware of:** TODO: e.g. will the site break?  Will actions behave strangely?
**More information:** see the [maintenance actions checklist](https://sleepdiary.github.io/internal-tools/maintenance-actions.html)

## Planning

1. [ ] ensure everyone involved in the project has followed the [maintainer environment recommendations](https://github.com/sleepdiary/docs/blob/main/development/maintainer-environment-recommendations.md)
2. [ ] ensure everyone has read about [minimising planned maintenance](https://github.com/sleepdiary/docs/blob/main/development/minimising-planned-maintenance.md) and can't think of a way to reduce this maintenance any further
3. [ ] look through [the list of previous planned maintenances](https://github.com/sleepdiary/internal-tools/issues?q=label%3Aplanned-maintenance) and find anything to learn from them
4. [ ] assign one person to lead this task
5. [ ] [fill out the maintenance actions](https://github.com/sleepdiary/planned-maintenance-times/edit/main/index.js)
6. [ ] see at least one update message from [the maintenance timer](https://github.com/sleepdiary/internal-tools/actions/workflows/maintenance-timer.yml)

The maintenance window should be reasonably pessimistic.  How long would it take to slowly follow all the steps, wait until you're sure an action has hung and isn't just being slow, run some diagnostics (that also hang), then follow the fallback procedure?

Some automations are based on these times.  No-one will mind if you manually close the maintenance window ahead of schedule, but continuing past the deadline can cause these scripts to misinform people or incorrectly disable safeguards.

## Fallback plan

1. [ ] write a series of steps (or ideally a single shell script) that will revert the whole project back to the state it was in at the start of the maintenance window.
2. [ ] test the steps on a personal repository
3. [ ] look for error messages in the actions' output that may not be reflected in the exit status
3. [ ] update this ticket with steps necessary to prepare for and execute the fallback plan
  (for example, the you will probably want to create some `last-known-good` branches)
4. [ ] be prepared to use these steps at the time you promised
5. [ ] make sure this plan will take less than half an hour to run
6. [ ] check all TODO items in this issue have been completed

```bash
# Example steps to revert:
SLEEPDIARY_ROOT=/path/to/sleepdiary
PUSH_LOCATION=safe-personal # while testing
#PUSH_LOCATION=unsafe-canonical # in practice
for REPO in # core dashboard info report sleepdiary.github.io
do cd "$SLEEPDIARY_ROOT/$REPO" && git revert last-known-good^..main && git push "$PUSH_LOCATION"
done
```

## Procedure

1. [ ] final check of [the maintenance actions](https://github.com/sleepdiary/planned-maintenance-times/edit/main/index.js)
2. [ ] check all items before this one have been ticked off
3. [ ] follow [the maintenance actions](https://github.com/sleepdiary/planned-maintenance-times/edit/main/index.js)
4. [ ] add a comment to any waiting branches that it's now safe to merge

## Review and process improvements

1. [ ] give everyone involved time to write up their thoughts (including notes made during the maintenance and thoughts that occurred in the following days)
2. [ ] ensure everyone's comments are included in this issue
3. [ ] compile a list of things that went well, and ways to bake them into the process for the future
4. [ ] compile a list of things that went badly (or could have gone badly), and ways to improve the system to avoid them in future
5. [ ] implement as many improvements as possible
  - reference this issue in all relevant PRs
