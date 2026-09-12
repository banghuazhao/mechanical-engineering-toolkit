# Changelog

## Unreleased

- Added a Thermodynamics category, the first new subject since Fluids & Thermal: steam tables computed from IAPWS-IF97 (saturation by temperature or pressure, and single states from pressure with temperature, quality, enthalpy or entropy), ideal gas processes, the air-standard Otto, Diesel and Brayton cycles, and the Rankine steam cycle with turbine and pump efficiencies. The cycles come with their state tables and p–v and T–s diagrams, drawn over the saturation dome where steam is the working fluid.
- On a wide window a tool now shows its result beside its inputs instead of over them, so changing a number and recalculating no longer means paging back and forth. Below 1000 points wide — every phone, and a narrow Mac window — the result opens as its own page exactly as before.
- The Mac app has a real menu bar in place of the Flutter template's, whose Preferences… and Find… did nothing. Calculate is ⌘↩, Find Tool ⌘F, Save to Project ⌘S, Share or Export ⌘E, and ⌘? opens the open tool's explanation; the Go menu reaches the library, favourites, history and projects, and View switches between SI and Imperial units. Items that nothing on screen can answer are greyed out rather than silently doing nothing.
- The tool library gets a sidebar on a wide window, with every category and the counts in each, in place of the drawer that had to be summoned.
- History now keeps the last 500 calculations instead of 50, and the Premium copy says so rather than promising a "full history" that stopped at fifty.
- Standard sections can now fill Column Buckling (the weak-axis Iy, which governs an unbraced column), Beam Flexure, Transverse Shear (Q, Ix and the web thickness at the neutral axis) and Combined Loading, as they already did for the beam tools.
- Added composite lamina presets — T300/5208, AS/3501, B(4)/5505, Scotchply 1002 and Kevlar 49/epoxy — filling E1, E2, G12 and ν12 across the composite tools, and the strengths in the Tsai failure criteria.
- Added thirteen isotropic materials: 1018, 1045 and 4140 steels, A572 Gr 50, 316 stainless, 2024-T3, 7075-T6 and 5052-H32 aluminium, Inconel 718, AZ31B magnesium, ductile iron, polycarbonate and acetal.
- Both fatigue tools now draw the Goodman diagram behind their answer — the failure line, the design line at 1/n, and where the part sits on it. Shaft Fatigue Design also reports the von Mises alternating and mean stresses at the diameter it sizes.
- Fixed a saved project from Shaft Fatigue Design not finding its way back to the tool in any language but English: the result page named itself with an English literal.
- Fixed specific volumes printing as a bare "0.001": values below 0.01 now use exponential form, as the fluid viscosities already did.
- Added a macOS app. It is a second platform on the existing App Store record — a Universal Purchase sharing the iOS bundle identifier — so it carries no ads, opens at a sensible desktop window size, and reports its Mac model in feedback mail.
- The Mac app ships a free tier and a Premium unlock. Free covers every reference table and at least one calculator in each of the nine categories, results on screen, copying values, and sharing as text. Premium adds the rest of the sixty-four tools, PDF, CSV and image export, saved projects, the calculation history beyond the last five entries, and the what-if sweep charts.
- Premium is the *same* in-app purchase as Remove Ads on iOS, so buying on either an iPhone, an iPad or a Mac unlocks all of them. Nothing is gated on iOS or Android, where the tools stay free and ad-supported.
- Locked tools stay visible in the library behind a "Premium" badge rather than being hidden, and every locked action explains what it is before offering the upgrade.
- Fixed the Mac window forgetting its size and position: it was applying the default size on every launch instead of restoring the saved frame.

## 1.12.0 - 2026-09-07

- Beam Load Analysis now solves any of six support arrangements — simply supported, cantilever fixed at either end, overhang on inset supports, propped cantilever and fixed at both ends — carrying any number of point loads, uniform, triangular or trapezoidal distributed loads, and applied couples. The three indeterminate cases are solved by the direct stiffness method, and the result separates the sagging and hogging peaks and adds the bending stress when a section depth is given.
- Added a bolt grades and torque reference: ISO 898-1 metric property classes and SAE J429 inch grades, with tensile stress area, proof strength, clamp load and tightening torque for every size and grade.
- Added a Power Screw calculator under Machine Design: torque to raise and lower, efficiency, and whether the screw is self-locking, for square, ACME and trapezoidal threads.
- Saved beam calculations from before this release still reopen, with their point load and UDL carried across.
- Removed two superseded beam files that were no longer reachable from the app: a beam-reactions page dead since 1.4.0, and the single-case simply-supported calculator the new solver replaces.
- Rebuilt the PDF export's CJK font subsets, which had not been regenerated since 1.10.0 and were missing characters added since. They no longer carry the help-sheet prose, which never reaches a report, so they stay near their previous size despite covering more.

## 1.11.0 - 2026-08-28

- Added an explanation for every tool behind a "?" in its app bar, covering what the tool computes, the formula it uses, and how to read the result — translated into German, French, Japanese, Simplified Chinese and Traditional Chinese.
- Added Tolerance Stack-Up analysis over a dimension chain of any length, by both the worst-case and RSS methods, reporting the closing gap's limits and which dimension owns most of the variation.
- Added standard pipe schedules (ASME B36.10M, NPS 1/8 to 24, schedules 10/40/80/160) as a browsable reference, with a picker that fills Reynolds Number and Pipe Pressure Drop from the real bore.
- Projects now hold several calculations instead of one tool's inputs, and export as a single PDF report with a contents list.
- Fixed the bore quoted against the name for NPS 1 pipe in the tool explanations.
- Fixed a saved stack-up being summarised as raw JSON instead of its dimensions.
- Fixed the stack-up result showing each contribution share twice.

## 1.10.0 - 2026-08-20

- Added three vibration tools under Machine Design: shaft critical speed (Dunkerley), beam natural frequency across five end conditions, and torsional natural frequency for one or two rotors.
- Beam natural frequency can be filled straight from the standard-section picker.
- Added the Remove Ads purchase on Android, with purchase restoration.
- Fixed a launch delay caused by the store check running before the first frame.
- Fixed restore on Android reporting unpaid or pending orders as restored.
- Fixed a pending purchase leaving the buy button spinning and restore disabled.
- Updated the Android app-open test ad unit used in development builds.

## 1.9.0 - 2026-08-14

- Added a new Fluids & Thermal category: Reynolds number and flow regime, pipe pressure drop (Darcy–Weisbach with a Colebrook friction factor), pump and fan power, composite wall conduction, fin efficiency, and heat exchanger sizing by LMTD.
- Added a fluid property picker covering water, air, oils, glycol, glycerin, kerosene and mercury, so density and viscosity are filled as a matching pair.
- Added a thermal material picker covering metals, building materials and insulation.
- Added a Standard Sections reference covering AISC W shapes and European IPE and HEB shapes, with a full property sheet per shape that exports like any other result.
- Beam Section Properties and Beam Load Analysis can now be filled straight from a standard section.
- Fixed PDF export of results in Chinese and Japanese.
- Raised the minimum supported iOS version to 15.0.
- Updated the Google Mobile Ads SDK.

## 1.8.0 - 2026-08-08

- Added Projects: save any calculation's inputs under a name and reopen it later.
- Added CSV and PDF export on every result page.
- Added a single share action with a format picker (text, image, CSV, PDF).
- Added a light / dark / system appearance setting.
- Localized the high-traffic interface strings and fixed search in non-English languages.
- Fixed a crash when naming a project on iOS.

## 1.7.0 - 2026-08-02

- Added a searchable drill & tap chart covering standard tap and clearance drill sizes.
- Added an ISO 286 fits & tolerances reference table.
- Added an in-app language switcher in the side menu.
- Added German, French, and Japanese translations.
- Fixed the Android minimum supported version, which was raised to Android 16 by mistake in 1.6.0 and prevented installation on most devices.

## 1.6.0 - 2026-07-23

- Added a new Machine Design category: helical compression spring, spur gear geometry, shaft fatigue sizing, bearing L10 life, belt/chain drive, bolt preload, fillet weld strength, and press/shrink-fit interference calculators.
- Added Composite failure criteria (Tsai-Hill and Tsai-Wu).
- Added custom tool illustrations and animated icon transitions from the list into each calculator and its results.
- Improved "Recommended by Major" coverage so more tools surface under each major.
- Refined the material preset picker, parameter sweep, and result page headers.

## 1.5.0 - 2026-07-17

- Added Mohr's Circle, Bolted Joint, Combined Loading, and Fatigue Safety Factor calculators.
- Added Truss Analysis for 2D statics problems.
- Added a unified SI / Imperial unit system across calculators, with a setting to choose your preferred units.
- Added major-based tool discovery to help students find the right calculators faster.
- Fixed App Tracking Transparency so the permission prompt appears before ads initialize.

## 1.4.0 - 2026-07-12

- Added Beam Section Properties and Beam Load Analysis calculators with formulas, substituted calculation steps, and engineering diagrams.
- Added an iOS one-time purchase to permanently remove advertising, including purchase restoration.
- Added certified consent handling and privacy choices for advertising in supported regions.
- Redesigned the app with responsive list and grid views, clearer calculator cards, and improved navigation.
- Improved calculation result consistency, keyboard dismissal, accessibility, history, and sharing behavior.
- Fixed the iOS App Tracking Transparency prompt so it appears before consent and advertising initialization on a fresh install.
