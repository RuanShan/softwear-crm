$("#js-email-customer").ready ->
  initializeSummernote();
  initializeProofSummernote();
  setSubmitTimeout();
  summernoteSubmit();