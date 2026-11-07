import {
  assertActiveSections,
  assertChildAudience,
  audience,
  canAccessSectionContent,
} from "./section_audience.ts";

function assert(value: unknown, message: string) {
  if (!value) throw new Error(message);
}
function rejects(fn: () => void) {
  let rejected = false;
  try {
    fn();
  } catch (_) {
    rejected = true;
  }
  assert(rejected, "Expected rejection");
}
const base = {
  studentId: "student",
  courseId: "course",
  moduleId: "module",
  enrollment: {
    studentId: "student",
    courseId: "course",
    sectionId: "4c",
    status: "active",
  },
  module: { courseId: "course", status: "published", sectionIds: ["4c"] },
};
Deno.test("4C module rejects 4D, including direct access", () => {
  assert(canAccessSectionContent(base), "4C should read");
  assert(
    !canAccessSectionContent({
      ...base,
      enrollment: { ...base.enrollment, sectionId: "4d" },
    }),
    "4D must not read",
  );
});
Deno.test("multiple selected sections and all sections work", () => {
  assert(
    canAccessSectionContent({
      ...base,
      module: { ...base.module, sectionIds: ["4c", "4d"] },
    }),
    "multi section",
  );
  assert(
    canAccessSectionContent({
      ...base,
      module: { ...base.module, sectionIds: ["*"] },
    }),
    "all sections",
  );
});
Deno.test("children and existing assessment section cannot widen parent", () => {
  const child = {
    courseId: "course",
    moduleId: "module",
    status: "published",
    sectionIds: ["*"],
  };
  assert(
    canAccessSectionContent({ ...base, child }),
    "parent still restricts shared child",
  );
  assert(
    !canAccessSectionContent({ ...base, child: { ...child, sectionId: "4d" } }),
    "single-section quiz intersection",
  );
  assert(
    !canAccessSectionContent({
      ...base,
      child: { ...child, sectionIds: ["4d"] },
    }),
    "narrow child",
  );
  assert(
    !canAccessSectionContent({
      ...base,
      child: { ...child, moduleId: "foreign" },
    }),
    "foreign module",
  );
  rejects(() => assertChildAudience(["4c"], ["*"]));
  rejects(() => assertChildAudience(["4c"], ["4d"]));
});
Deno.test("legacy data stays shared but malformed audiences fail closed", () => {
  assert(
    canAccessSectionContent({
      ...base,
      module: { courseId: "course", status: "published" },
    }),
    "legacy module",
  );
  for (const sectionIds of [[], null, "4c", ["*", "4c"], ["4c", "4c"]]) {
    assert(
      !canAccessSectionContent({
        ...base,
        module: { ...base.module, sectionIds },
      }),
      "malformed data denied",
    );
    rejects(() => audience(sectionIds));
  }
});
Deno.test("inactive enrollment, foreign course and unpublished module are denied", () => {
  assert(
    !canAccessSectionContent({
      ...base,
      enrollment: { ...base.enrollment, status: "removed" },
    }),
    "removed",
  );
  assert(
    !canAccessSectionContent({
      ...base,
      module: { ...base.module, courseId: "other" },
    }),
    "foreign",
  );
  assert(
    !canAccessSectionContent({
      ...base,
      module: { ...base.module, status: "draft" },
    }),
    "draft",
  );
});
Deno.test("only active owned-course sections can be assigned", () => {
  const sections = [{ id: "4c", courseId: "course", status: "active" }, {
    id: "4d",
    courseId: "course",
    status: "archived",
  }];
  assertActiveSections(["4c"], "course", sections);
  rejects(() => assertActiveSections(["4d"], "course", sections));
  rejects(() => assertActiveSections(["missing"], "course", sections));
  rejects(() => assertActiveSections(["4c"], "other", sections));
});
