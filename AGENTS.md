## Project Instruction Rules

* Before doing any work in this repository, read this AGENTS.md file and follow it strictly.
* Apply these rules in every Codex chat for this project, including new chats.
* If a task conflicts with these rules, mention the conflict before changing code.

## Coding Rules

* Make minimal, surgical changes.
* Do not rewrite unrelated code.
* Think before coding.
* Explain approach before implementation when possible.
* Do not hallucinate APIs.
* Verify code compiles.

## Naming Rules

* Name variables and properties from general → specific.
* The main entity or domain term should come first, followed by modifiers or state.
* Prefer titleProcessed over processedTitle.
* Prefer tokenNotificationUser over userNotificationToken.
* Prefer imageOriginal over originalImage.
* Prefer messageError over errorMessage.
* Keep naming order consistent across models, services, and UI state.
* Avoid mixing naming directions within the same file or feature.
* Function names should clearly describe the action being performed.
* Prefer getProcessedValue() over processedValue().
* Prefer loadImagePreview() over imagePreview() when the function performs work.
* Use verbs for function names and nouns for stored properties.
* Use full names insted of two-three characters name. Prefer friendlyName instead of fn.
* Name callback/action closures with an Action suffix.
* Prefer domain-action names like saveFormAction over event-style names like onSaveForm.
* Keep SwiftUI builder closures and framework API labels unchanged, for example content, Button(action:), and onChange.

## SwiftUI Rules

* Keep views small and composable.
* Avoid rewriting existing layouts.
* Follow existing architecture patterns.
* Prefer native SwiftUI APIs and modern platform conventions.
* Avoid UIKit bridges unless the task explicitly requires them.
* Do not introduce third-party frameworks without asking first.
* Split large SwiftUI screens into small private subviews or focused files when it improves readability.
* Keep state ownership clear: views own local UI state, shared app state stays in the existing model/store layer.
* Avoid heavy work, network calls, database writes, and formatter creation directly inside body.
* Use NavigationStack, sheets, alerts, confirmation dialogs, and toolbar APIs consistently with the existing app.
* Prefer foregroundStyle over foregroundColor for new SwiftUI code unless compatibility requires otherwise.
* Support accessibility by default: meaningful labels, Dynamic Type-friendly layout, Reduce Motion-safe animation, and tappable controls with clear hit areas.
* Keep animations purposeful and lightweight. Do not add decorative motion that is not present in the existing design or requested by the user.

## Swift Pro Review Rules

* When reviewing or changing SwiftUI, check correctness, modern API usage, data flow, navigation, accessibility, performance, and code hygiene.
* Report and fix only real issues. Do not invent problems or rewrite code for personal taste.
* Preserve the current architecture and feature boundaries.
* Prefer Swift concurrency patterns already used in the project.
* Keep each type focused. Avoid placing unrelated structs, classes, and enums in the same file.
* Make the smallest change that solves the problem and keeps the code easy to maintain.

## Figma Implementation Rules

* When implementing from Figma, use exact values from the Figma design instead of guessing.
* Match font family, font size, font weight, line height, letter spacing, text case, alignment, and truncation behavior from Figma.
* Match colors using exact hex/RGBA values or existing design tokens that resolve to the same values.
* Match spacing, padding, margins, corner radius, stroke width, opacity, shadow, blur, and layout constraints from Figma.
* Match component states from Figma, including default, pressed, disabled, selected, loading, empty, and error states when they are provided.
* Use exported or referenced assets from Figma when available. Do not replace them with approximate SF Symbols, gradients, or placeholder shapes unless requested.
* If Figma uses a design system token, component, or style, prefer the matching code token/component/style over hardcoded values.
* If an exact Figma value is missing or ambiguous, inspect the file again or ask for clarification. Do not fill gaps with personal taste.
* Do not add extra visual effects, colors, animations, rounded corners, or layout changes that are not in Figma or the existing app.
* After implementing a Figma screen, compare the result against the design for font sizes, colors, spacing, alignment, and visible states before finishing.

## SwiftData Rules

* Do not rename persisted fields without migration.
* Preserve @Model integrity.

## Swift Structure Style Rules

* Use block `MARK` comments inside Swift types to make the file easy to scan.
* Use `MARK: - Properties` before stored properties, property wrappers, environment values, and computed properties.
* Use `MARK: - Init` before custom initializers.
* Use `MARK: - Body` before `var body: some View`.
* Use `MARK: - Actions` before action methods and action closures extracted from `body`.
* Use `MARK: - Helpers` before helper methods.
* Use a more specific section name when it reads better, for example `MARK: - Shape` before `path(in:)` in `Shape` types.
* Inside larger SwiftUI builders, use empty block separators to visually divide logical layout groups.
* Add empty block separators only when they improve readability of a non-trivial `body` or view builder. Do not add them to tiny views where the structure is already obvious.
* Keep the ordering of sections consistent: properties first, then init, then body, then actions/helpers.

### Preferred

```swift
private struct ExampleView: View {

    /*
     MARK: - Properties
     */

    let title: String
    let saveAction: () -> Void

    /*
     MARK: - Body
     */

    var body: some View {
        HStack(spacing: 8.0.scaled) {

            /*
             */

            Text(title)

            /*
             */

            Button("Save", action: saveAction)
        }
    }
}
```

## Swift Formatting Rules

* Format every guard statement as a multiline block.
* Place guard on its own line.
* Place every condition on a separate line.
* Place else { return } on a separate line.
* Add a blank line after the complete guard statement.
* Format compound condition statements as multiline blocks.
* Apply the same condition style to if, else if, guard, while, and similar Swift condition statements.
* Prefer comma-separated Swift condition lists over joining conditions with &&.
* Place the opening { on its own line for multiline condition statements.
* Exception: when `if`, `else if`, or `while` has exactly one condition, keep it on one line with the opening `{`.
* This exception includes a single optional binding, for example `if let viewControllerPresented = viewControllerBase?.presentedViewController {`.
* Keep `guard` statements multiline even when they have one condition.

### Preferred

```swift
guard
    condition
else { return }

guard
    conditionFirst,
    let value,
    value.isEmpty == false
else { return }

if
    conditionFirst,
    conditionSecond
{
    runAction()
} 
else if
    conditionFallback,
    conditionFallbackSecond
{
    runFallbackAction()
}
else
{
    runFallbackEndAction
}

if let value {
    runAction()
}
```
