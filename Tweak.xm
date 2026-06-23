%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{

        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"DYLIB WORKING"
                                            message:@"Injection Successful"
                                     preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *ok =
        [UIAlertAction actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:nil];

        [alert addAction:ok];

        UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
        [window.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}
