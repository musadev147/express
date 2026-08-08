
PostRegisterRx postRegisterRx = PostRegisterRx(
  empty: PostRegisterModel(),
  dataFetcher: BehaviorSubject<PostRegisterModel>(),
);
PostSignInRx postSignInRx = PostSignInRx(
  empty: PostSignInModel(),
  dataFetcher: BehaviorSubject<PostSignInModel>(),
);
PostResendEmailVerificationRx postResendEmailVerificationRx =
    PostResendEmailVerificationRx(
      empty: PostResendEmailVerificationModel(),
      dataFetcher: BehaviorSubject<PostResendEmailVerificationModel>(),
    );

ForgotEmailRx forgotEmailRx = ForgotEmailRx(
  empty: PostForgetPassModel(),
  dataFetcher: BehaviorSubject<PostForgetPassModel>(),
);

PostOtpRx postOtpRx = PostOtpRx();

PostResetOtpRx postResetOtpRx = PostResetOtpRx();

ForgotNewPasswordRx forgotNewPasswordRx = ForgotNewPasswordRx(
  empty: PostResetPassModel(),
  dataFetcher: BehaviorSubject<PostResetPassModel>(),
);

PostLogoutRX postLogoutRX = PostLogoutRX(
  empty: PostLogOutModel(),
  dataFetcher: BehaviorSubject<PostLogOutModel>(),
);

GetUserDataRx getUserDataRx = GetUserDataRx(
  empty: GetProfileModel(),
  dataFetcher: BehaviorSubject<GetProfileModel>(),
);

