class Submission {
  String? submissionId;
  String? workId;
  String? title;
  String? submissionText;
  String? submittedAt;

  Submission({
    this.submissionId,
    this.workId,
    this.title,
    this.submissionText,
    this.submittedAt,
  });

  Submission.fromJson(Map<String, dynamic> json) {
    submissionId = json['submission_id']?.toString();
    workId = json['work_id']?.toString();
    title = json['title'];
    submissionText = json['submission_text'];
    submittedAt = json['submitted_at'];
  }

  Map<String, dynamic> toJson() {
    return {
      'submission_id': submissionId,
      'work_id': workId,
      'title': title,
      'submission_text': submissionText,
      'submitted_at': submittedAt,
    };
  }
}
