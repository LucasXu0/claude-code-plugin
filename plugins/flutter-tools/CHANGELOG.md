# Changelog

All notable changes to this project will be documented in this file.

## [2.2.1] - 2026-01-05

### Fixed
- Fixed debug info not displaying in flutter-review agent output
- Made Step 0 verification more concrete and actionable by providing explicit output format
- Agent now always shows debug status at start instead of attempting undefined skill introspection

## [1.2.0] - 2026-01-04

### Changed
- **BREAKING**: Restructured knowledge architecture for better maintainability
- SKILL.md now uses compact format with cross-references to reference.md
- Reduced SKILL.md from 384 to 341 lines (11% reduction)
- All check descriptions now include anchor links to detailed documentation

### Added
- Comprehensive anchor IDs in reference.md for all checks
- Detailed pattern explanations for Bloc and Provider in reference.md
- Complete code examples for all new P1 checks in examples.md
- Cross-file referencing system between SKILL.md, reference.md, and examples.md

### Improved
- Reduced content duplication across skill files
- Better separation of concerns: skill (compact) vs reference (detailed) vs examples (code)
- Enhanced Long Classes check with dead code detection methodology
- Progressive disclosure: SKILL → reference → examples workflow

## [1.1.0] - 2026-01-04

### Added
- P1 check for multiple widget definitions in same file
- P1 check to avoid late keyword usage (runtime safety)
- P1 check for long build methods (>50 lines) in widgets
- Enhanced P2 long class check to identify useless/dead code

## [1.0.0] - 2026-01-04

### Added
- Initial plugin release
- Flutter code review agent with P0/P1/P2 analysis
- Automated formatting workflow skill
- Bloc and Provider anti-pattern detection
- Progressive disclosure architecture
- Optimized performance (50-70% faster reviews)
- Marketplace support for plugin installation via `/plugin install`
