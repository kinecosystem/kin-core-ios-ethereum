bundle install

bundle exec jazzy \
            --source-directory KinSDK \
            --output Docs/Output \
            --github_url https://github.com/kinfoundation/kin-sdk-core-ios \
            --github-file-prefix https://github.com/kinfoundation/kin-sdk-core-ios/blob/dev/KinSDK \
            --author "Kin Foundation" \
            --author_url https://kin.kik.com \
            --module KinSDK \
            --readme README.md \
            --sdk iphone
