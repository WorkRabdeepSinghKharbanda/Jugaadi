/// Status values for `jobs.status` (JobStatus) and `job_applications.status`
/// (ApplicationStatus) — the two status concepts in the schema. Keep in sync with whatever
/// values the backend actually sends/accepts.
enum JobStatus {
  open,
  hired,
  done,
  removed;

  static JobStatus? fromString(String? value) {
    for (final s in values) {
      if (s.name == value) return s;
    }
    return null;
  }

  @override
  String toString() => name;
}

enum ApplicationStatus {
  pending,
  accepted,
  rejected;

  static ApplicationStatus? fromString(String? value) {
    for (final s in values) {
      if (s.name == value) return s;
    }
    return null;
  }

  @override
  String toString() => name;
}
