import ProjectDescription

let project = Project(
    name: "Zellij-Sweep",
    options: .options(
        automaticSchemesOptions: .disabled
    ),
    settings: .settings(
        base: [
            "CURRENT_PROJECT_VERSION": "3",
            "MARKETING_VERSION": "1.0.2",
            "MACOSX_DEPLOYMENT_TARGET": "14.0",
            "SWIFT_VERSION": "6.0",
            "PRODUCT_NAME": "Zellij-Sweep",
            "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",
            "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
        ]
    ),
    targets: [
        .target(
            name: "ZellijSweep",
            destinations: .macOS,
            product: .app,
            bundleId: "dev.jldrmn.Zellij-Sweep",
            deploymentTargets: .macOS("14.0"),
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "Zellij-Sweep",
                    "LSApplicationCategoryType": "public.app-category.utilities",
                    "LSUIElement": true,
                    "NSHumanReadableCopyright": "Zellij-Sweep © [Jean-Louis Darmon]",
                ]
            ),
            sources: ["Sources/**"],
            resources: [
                .glob(
                    pattern: "Resources/**",
                    excluding: [
                        "Resources/AppIcon.icon/**",
                    ]
                ),
            ],
            dependencies: []
        ),
    ],
    schemes: [
        .scheme(
            name: "Zellij-Sweep",
            shared: true,
            buildAction: .buildAction(targets: ["ZellijSweep"]),
            runAction: .runAction(configuration: .debug)
        ),
    ]
)
