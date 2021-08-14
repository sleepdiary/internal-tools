---
name: Planned maintenance
about: Tracking ticket for planned maintenance
title: "[Planned maintenance]: TODO: purpose of this maintenance"
labels: planned-maintenance
assignees: ''

---

This issue tracks a period of planned maintenance.  For example, an update that risks breaking the site for users or causing automated actions to fail.  You should only use this if you maintain the sleepdiary project.

## Summary

**Reason for maintenance:** TODO: one line explanation of why this maintenance is required
**Maintenance window:** TODO: start and end times
**Issues to be aware of:** TODO: e.g. will the site break?  Will actions behave strangely?

## Planning

1. [ ] ensure everyone involved in the project has followed the [maintainer environment recommendations](https://github.com/sleepdiary/docs/development/maintainer-environment-recommendations.md)
2. [ ] ensure everyone has read about [minimising planned maintenance](minimising-planned-maintenance.md) and can't think of a way to reduce this maintenance any further
3. [ ] look through [the list of previous planned maintenances](https://github.com/sleepdiary/internal-tools/issues?q=label%3Aplanned-maintenance) and find anything to learn from them
4. [ ] assign one person to lead this task
5. [ ] fill out the summary above
6. [ ] [update the planned maintenance times](https://github.com/sleepdiary/planned-maintenance-times/edit/main/index.js) to match the summary
7. [ ] make sure [the maintenance timer](https://github.com/sleepdiary/internal-tools/actions/workflows/maintenance-timer.yml) is sending regular messages to this issue

The maintenance window should be reasonably pessimistic.  How long would it take to slowly follow all the steps, wait until you're sure an action has hung and isn't just being slow, do some more test runs to generate all the diagnostics you need, then run the fallback procedure?

Some automations below will be based on these times.  No-one will mind if you manually close the maintenance window ahead of schedule, but setting times that are too short (or going past your deadline) can cause these scripts to misinform people or incorrectly disable safeguards.

## Fallback plan

1. [ ] write a series of steps (or ideally a single shell script) that will revert the whole project back to the state it was in at the start of the maintenance window.
2. [ ] test the steps on a personal repository
3. [ ] update this ticket with steps necessary to prepare for and execute the fallback plan
  (for example, the you will probably want to create some `last-known-good` branches)
4. [ ] be prepared to use these steps at the time you promised
5. [ ] make sure this plan will take less than half an hour to run

```bash
# For example:
SLEEPDIARY_ROOT=/path/to/sleepdiary
PUSH_LOCATION=safe-personal # while testing
#PUSH_LOCATION=unsafe-canonical # in practice
for REPO in # core dashboard info report sleepdiary.github.io
do cd "$SLEEPDIARY_ROOT/$REPO" && git revert last-known-good^..main && git push "$PUSH_LOCATION"
done
```

## Procedure

1. [ ] check [the maintenance times](https://github.com/sleepdiary/planned-maintenance-times/edit/main/index.js) match the summary
2. [ ] check the current time (GMT) is within the window mentioned at the top of this issue
3. [ ] open the following browser tabs (TODO: add links):
  - [sleepdiary.github.io](https://sleepdiary.github.io/)
  - [sleepdiary.github.io/dashboard](https://sleepdiary.github.io/dashboard)
  - [your notifications page](https://github.com/notifications)
  - [the list of Sleep Diary repositories](https://github.com/orgs/sleepdiary/repositories)
  - the "code" and "actions" pages for every relevant repository
  - [the forum](https://github.com/sleepdiary/sleepdiary.github.io/discussions)
  - any tabs necessary to talk with other maintainers
  - a search engine
4. [ ] check all TODO items in this issue have been completed, and all items before this one have been ticked off
5. [ ] push new branches called `last-known-good` to any relevant repositories
6. [ ] push new branches named after this issue to any relevant repositories
  (the branch names must begin with `maint-` so the [planned-maintenance action](https://github.com/andrew-sayers/planned-maintenance) knows what to do)
7. [ ] create pull requests for each branch
  - the pull requests should reference this issue
  - the merge commit bodies should reference this issue
  - the merge commit titles should be something like "Initial merge for *issue*"

TODO: Fill in the details here for this maintenance.  Make sure to include:

- steps you will need to carry out
- things to monitor (e.g. web sites, actions)
- tests to perform after the maintenance is complete

1. [ ] push a final merge to each repository, including all pushed commits during the maintenance window
  - do this even if there were no extra changes after the first PR - the extra PR confirms the lack of changes to anyone reviewing the commit history
  - example commands:
    ```bash
    MAINTENANCE_BRANCH=maint-...
    git checkout main
    git reset --hard last-known-good
    git merge --no-ff origin/main -m "Merge branch '$MAINTENANCE_BRANCH' into main"
    git push unsafe-canonical main
    ```
2. [ ] delete all the `last-known-good` branches created earlier
3. [ ] delete any PR branches created earlier
4. [ ] add a comment to this issue, stating whether the maintenance was successful, and what happened if not
5. [ ] update [the maintenance times](https://github.com/sleepdiary/planned-maintenance-times/edit/main/index.js) and set the end of the maintenance window
6. [ ] add a comment to any waiting branches that it's now safe to merge

## Review and process improvements

1. [ ] give everyone involved time to write up their thoughts (including notes made during the maintenance and thoughts that occurred in the following days)
2. [ ] ensure everyone's comments are included in this issue
3. [ ] compile a list of things that went well, and ways to bake them into the process for the future
4. [ ] compile a list of things that went badly (or could have gone badly), and ways to improve the system to avoid them in future
5. [ ] implement as many improvements as possible
