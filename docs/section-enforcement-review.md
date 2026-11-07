# Section enforcement review — not ready for production deployment

## Implemented foundation

`supabase/functions/_shared/section_audience.ts` defines the shared server policy:
- `sectionIds: ['*']` means all sections; otherwise use one or more unique section IDs.
- Missing legacy fields remain shared. Empty, malformed, duplicate and mixed wildcard lists are rejected.
- A child audience may narrow its module audience but cannot expand it.
- Active enrollment, matching course/module, publication state and the existing assessment `sectionId` restriction are checked together.
- Active-section validation rejects deleted, archived and foreign-course section assignments.

The policy has six executable Deno tests covering these cases. It is not yet connected to request handlers, so it does not itself restrict the current application.

## Additional storage boundary discovered

`LearningMaterialService` uploads materials to `caslms-learning-materials` and saves public URLs using `getPublicUrl`. Firestore filtering cannot protect files already accessible through public URLs. A full implementation must make protected material storage private, remove public read policies, issue short-lived signed URLs after Firebase Auth/App Check and enrollment/audience checks, and update every viewer/AI source reader. Existing downloaded copies cannot be revoked.

Do not change the bucket to private before updating viewers and the signed URL endpoint; otherwise existing materials will stop opening.

## Required integrated work before enabling the creation prompt

1. Add explicit audience selection to module creation and material/assessment creation. Default to the validated current section; require explicit confirmation for all sections. Child choices must be limited to the module audience.
2. Persist validated `sectionIds` during creation, never as an after-the-fact update to already-published unrestricted content. Do not use a write-then-restrict sequence.
3. Modify instructor queries and cards to show assigned audiences, not merely the current view filter. Existing shared records must remain labeled shared until deliberately reassigned.
4. Update student module/material/assessment queries, course cards, progress, calendar, AI attachment browsing and record queries. Query constraints must match Firestore rules; rules do not filter unauthorized results out of broad queries.
5. Replace the existing broad `isActive()` module/resource read grants. Adding a second restrictive match does not override those grants because Firebase allows are additive.
6. Enforce module and child audiences in all assessment submission, AI quiz publication/submission, compliance, signed-file and legacy quiz paths. Firebase Admin SDK calls bypass Firestore rules and need explicit policy checks.
7. Restrict notification fanout in both client `NotificationService` and Firebase notification functions. Do not notify 4D about 4C-only content.
8. Decide the audience-change protocol. Changing a published parent must invalidate affected child visibility, submissions and cached links consistently. A batch or server transaction must prevent intermediate broad access.
9. Test Firebase rules with a local emulator: 4C reads, 4D denied, direct record IDs denied, narrowed children, unpublished content, legacy data, revoked enrollment, account changes and parent/child race conditions. Test storage URLs as well.
10. Coordinate backend/rules/query rollout. Keep the existing frontend behavior until all enforcement paths and compatible queries are reviewed and deployed together.

## Deployment ownership

User has authorized implementing backend/rule changes for review. No Firebase administrator session is available here; the classmate must deploy the reviewed Firebase rules/functions and approve storage policy changes. No production rules, policies, bucket settings, content records or deployed frontend were changed by this foundation stage.
