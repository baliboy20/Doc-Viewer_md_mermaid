# Rome Doc Viewer - Git Integration Implementation Roadmap

**Version:** 1.0
**Date:** 2025-12-06
**Status:** Ready to Execute

---

## Overview

This roadmap outlines the complete implementation of Git version control integration into the Rome Doc Viewer application, including necessary architectural refactoring.

---

## Three-Phase Approach

### **Phase 0: Current State**
✅ **Completed** - v1.5.0 "Martinique"
- Annotation system with visual markers
- Custom speech bubble tooltips
- Improved scroll-to accuracy
- Clean Architecture (layer-based)

---

### **Phase 1: Architectural Refactoring**
📋 **Next** - v1.6.0 "Nassau" (4 weeks)

**Goal:** Refactor to feature-based architecture + implement go_router

**Why Required:**
- Isolate Git integration as separate feature
- Prevent tight coupling between features
- Enable scalable team development
- Establish routing infrastructure

**Deliverables:**
1. ✅ Feature-based directory structure (`lib/features/`)
2. ✅ go_router for all navigation (dialogs, screens)
3. ✅ Core shared code in `lib/core/`
4. ✅ macOS Keychain entitlements configured
5. ✅ All existing features working in new structure

**Timeline:**
- **Week 1:** Setup infrastructure, create directories, implement routing
- **Week 2:** Migrate documentation feature
- **Week 3:** Migrate annotations feature
- **Week 4:** Testing, cleanup, merge

**Document:** [`phase-1-refactoring-plan.md`](./phase-1-refactoring-plan.md)

---

### **Phase 2: Git Integration Implementation**
⏳ **Pending** - v2.0.0 "Osaka" (17 weeks)

**Goal:** Full Git version control integration

**Features:**
1. ✅ Clone remote repositories (HTTPS/SSH)
2. ✅ Create commits with messages
3. ✅ Push to remote
4. ✅ Pull on startup
5. ✅ Conflict detection & resolution

**Timeline:**
- **Weeks 1-3:** Foundation (clone, open, credentials)
- **Weeks 4-6:** Commit management
- **Weeks 7-10:** Push/pull operations
- **Weeks 11-14:** Conflict resolution
- **Weeks 15-17:** Polish & edge cases

**Document:** [`git-integration-proposal.md`](./git-integration-proposal.md)

---

## Technical Decisions (Based on User Feedback)

### ✅ Credential Storage
**Decision:** Use `flutter_secure_storage`

**Rationale:**
- Simpler than manual Keychain integration
- Cross-platform (macOS, Linux, Windows)
- Industry standard
- Automatic encryption

**Required Configuration:**
```xml
<!-- macos/Runner/DebugProfile.entitlements -->
<!-- macos/Runner/Release.entitlements -->
<key>keychain-access-groups</key>
<array/>
```

---

### ✅ Migration Strategy
**Decision:** Refactor first, then add Git

**Rationale:**
- Establishes clean foundation
- Reduces risk of breaking changes
- Git integration becomes isolated feature
- Easier to test incrementally

**Approach:**
1. Phase 1: Refactor existing code
2. Test thoroughly
3. Phase 2: Add Git as new feature

---

### ✅ Routing Scope
**Decision:** Implement routing for ALL features

**What Gets Migrated:**
- Screens (SplashScreen, DocumentationScreen)
- Dialogs (AnnotationDialog, StyleSettingsDialog, HelpDialog)
- Future Git screens (CloneScreen, CommitScreen, ConflictResolutionScreen)

**Benefits:**
- Consistent navigation patterns
- Type-safe routes
- Better deep linking support
- Easier state management

---

### ✅ Breaking Changes
**Decision:** Accept breaking changes during refactoring

**Mitigation:**
1. Complete refactor first
2. Test thoroughly before adding new features
3. Update all imports
4. Document migration in CHANGELOG
5. Tag pre-refactor state for rollback

**Import Path Changes:**
```dart
// Before
import 'package:doc_viewer_app/domain/entities/annotation.dart';

// After
import 'package:doc_viewer_app/features/annotations/domain/entities/annotation.dart';
```

---

## Project Structure (Post-Phase 1)

```
lib/
├── core/                          # Shared/common code
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── seez_theme.dart
│   ├── widgets/                   # Shared widgets
│   ├── utils/                     # Utility functions
│   ├── constants/                 # App constants
│   └── routing/
│       ├── app_router.dart        # go_router config
│       └── route_paths.dart       # Route constants
│
├── features/                      # Feature modules
│   │
│   ├── documentation/             # Documentation viewing
│   │   ├── domain/
│   │   ├── infrastructure/
│   │   ├── application/
│   │   └── presentation/
│   │
│   ├── annotations/               # Annotation system
│   │   ├── domain/
│   │   ├── infrastructure/
│   │   ├── application/
│   │   └── presentation/
│   │
│   └── git/                       # Git integration (Phase 2)
│       ├── domain/
│       ├── infrastructure/
│       ├── application/
│       └── presentation/
│
└── main.dart
```

---

## Dependencies

### Phase 1 (Refactoring)
```yaml
dependencies:
  go_router: ^14.0.0
  flutter_secure_storage: ^9.0.0  # For Phase 2
```

### Phase 2 (Git Integration)
```yaml
dependencies:
  git2dart: ^1.x.x      # Git operations (libgit2 bindings)
```

---

## Version History

| Version | Code Name | Status | Features |
|---------|-----------|--------|----------|
| v1.5.0 | Martinique | ✅ Released | Annotations, visual markers, tooltips |
| v1.6.0 | Nassau | 📋 Next | Feature-based refactor, go_router |
| v2.0.0 | Osaka | ⏳ Planned | Git integration |

---

## Success Criteria

### Phase 1 (Refactoring)
- [ ] All existing features work unchanged
- [ ] Code organized in feature-based structure
- [ ] go_router handles all navigation
- [ ] No performance regressions
- [ ] All tests pass
- [ ] Documentation updated

### Phase 2 (Git Integration)
- [ ] Can clone repositories (95%+ success rate)
- [ ] Can create and view commits
- [ ] Can push/pull changes
- [ ] Can resolve conflicts (90%+ resolution rate)
- [ ] Performance meets NFRs (< 10s for typical operations)
- [ ] No repository corruption (< 0.1% rate)

---

## Risk Mitigation

### Phase 1 Risks

**Risk:** Breaking existing functionality during refactoring
**Mitigation:**
- Tag pre-refactor state for rollback
- Incremental migration (one feature at a time)
- Test after each migration step
- Keep refactoring branch separate until ready

**Risk:** Import path changes break code
**Mitigation:**
- Use IDE refactoring tools
- Update all imports systematically
- Search project for old import patterns
- Test compilation after each update

### Phase 2 Risks

**Risk:** Git repository corruption
**Mitigation:**
- Use well-tested libgit2 library
- Implement validation before operations
- Create backups before destructive operations
- Add repository integrity checks

**Risk:** Credential security issues
**Mitigation:**
- Use flutter_secure_storage (platform-native encryption)
- Never log credentials
- Implement credential timeout/expiry
- Support OAuth for major platforms (future)

---

## Timeline Summary

| Phase | Duration | Weeks | End Date (Estimated) |
|-------|----------|-------|---------------------|
| Phase 1: Refactoring | 4 weeks | Weeks 1-4 | 2025-01-03 |
| Phase 2: Git Integration | 17 weeks | Weeks 5-21 | 2025-05-02 |
| **Total** | **21 weeks** | **~5 months** | **May 2025** |

**Note:** Timeline assumes full-time development. Adjust based on actual availability.

---

## Next Steps

### Immediate Actions (This Week)

1. **Review Phase 1 Plan**
   - Read [`phase-1-refactoring-plan.md`](./phase-1-refactoring-plan.md)
   - Clarify any questions
   - Approve to proceed

2. **Setup Development Environment**
   - Create feature branch: `refactor/feature-based-architecture`
   - Tag current state: `v1.5.0-pre-refactor`
   - Add dependencies to `pubspec.yaml`

3. **Configure macOS Entitlements**
   - Update `macos/Runner/DebugProfile.entitlements`
   - Update `macos/Runner/Release.entitlements`
   - Add keychain-access-groups

4. **Begin Week 1**
   - Day 1: Create directory structure
   - Day 2-3: Setup routing infrastructure
   - Day 4-5: Move shared code to `core/`

### Before Starting

**Questions to Answer:**

1. **Timeline:** Is 4 weeks for Phase 1 acceptable?
2. **Testing:** Do you have existing automated tests?
3. **Version Number:** OK with v1.6.0 "Nassau"?
4. **Deployment:** Release v1.6.0 publicly or keep internal?
5. **Code Review:** Review weekly or at end of Phase 1?

---

## Documents Reference

| Document | Purpose |
|----------|---------|
| [`git-integration-proposal.md`](./git-integration-proposal.md) | Complete Git integration specification |
| [`git-integration-annotation-responses.md`](./git-integration-annotation-responses.md) | Technical decisions based on user feedback |
| [`phase-1-refactoring-plan.md`](./phase-1-refactoring-plan.md) | Week-by-week refactoring implementation |
| `IMPLEMENTATION_ROADMAP.md` (this file) | High-level overview and timeline |

---

## Questions or Concerns?

If you have any questions or concerns about this roadmap:

1. Add annotations to this document with your questions
2. We'll address them before starting Phase 1
3. The plan is flexible - we can adjust based on feedback

---

**Status:** ✅ Ready to begin Phase 1 upon approval

**Approved by:** ________________

**Start Date:** ________________
