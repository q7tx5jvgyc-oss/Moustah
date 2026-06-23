__attribute__((constructor))
static void init_dylib() {
    NSLog(@"🔥 MostashClicker dylib loaded");
}
