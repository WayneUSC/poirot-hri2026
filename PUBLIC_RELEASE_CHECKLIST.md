# Public Release Checklist

Use this checklist before pushing the repository to GitHub.

- [ ] Choose a repository visibility: public, private, or private first then public.
- [ ] Choose and add a license.
- [ ] Confirm all appendix figures are allowed to redistribute.
- [ ] Confirm all character images, posters, and game assets are allowed to redistribute.
- [ ] Replace placeholder Firebase URL values with a documented configuration path or environment-specific setup.
- [ ] Keep `ios-script-distributor/Scripts Distributor/GoogleService-Info.plist` out of git.
- [ ] Keep `android-script-distributor/app/google-services.json` out of git.
- [ ] Replace placeholder role-script PDF URLs with redistributable files or documented external assets.
- [ ] Replace placeholder clue-card image URLs with redistributable files or documented external assets.
- [ ] Add final CAD/STL/Rhino/STEP files if available.
- [ ] Run iOS script distributor after adding Firebase config and running `pod install`.
- [ ] Run Android build only if maintaining the Android reference implementation.
- [ ] Run iOS build on a physical iPhone.
- [ ] Run a final secret scan before making the repository public.
