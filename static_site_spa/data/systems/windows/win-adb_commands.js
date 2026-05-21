const commandList = {
    name: "ADB命令",
    commands: [
{
    desc: `adb`,
    code: [
        `adb shell pm uninstall * --user 0`,
        `adb shell pm uninstall com.oplus.securitykeyboard --user 0`,
        `adb shell pm uninstall --user 0 com.coloros.securityguard`,
        `adb shell pm uninstall --user 0 com.oplus.appdetail`,
        `adb shell pm uninstall --user 0 com.oplus.pay`,
        `adb shell pm uninstall --user 0 com.coloros.healthcheck`,
        `adb shell pm uninstall --user 0 com.oplus.healthservice`,
        `adb shell pm uninstall --user 0 com.nearme.instant.platform`,
        `adb shell pm uninstall --user 0 com.heytap.xgame`,
        `adb shell pm uninstall --user 0 com.android.bips`,
        `adb shell pm uninstall --user 0 com.heytap.quicksearchbox`,
        `adb shell pm uninstall --user 0 com.heytap.yoli`,
        `adb shell pm uninstall --user 0 com.coloros.sceneservice`,
        `adb shell pm uninstall --user 0 com.oplus.apprecover`,
        `adb shell pm uninstall --user 0 com.oplus.statistics.rom`,
        `adb shell pm uninstall --user 0 com.oplus.omoji`,
        `adb shell pm uninstall --user 0 com.vivo.browser`,
        `adb shell pm uninstall * --user 0`,
        `adb shell pm uninstall * --user 0`,
        `adb shell pm uninstall * --user 0`,
        `adb shell pm disable-user`,
        `adb shell pm uninstall --user 0 com.oplus.securitykeyboard`
    ]
}
    ]
};
