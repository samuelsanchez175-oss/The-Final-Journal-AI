---
name: ""
overview: ""
todos: []
---

# Enhance Rap Suggestion API Rules for Better Themes, Narrative Flow, and Coherence

## Overview

Improve the prompts and rules in `[XJournal AI/RapSuggestionAPI.swift](XJournal AI/RapSuggestionAPI.swift)` to make the "suggest next lines" feature produce more thematically consistent, narratively coherent, and musically sound suggestions.

## User Requirements

### Primary Focus Areas:

1. **Thematic Consistency** - Better enforcement of theme matching
2. **Narrative Flow** - Better narrative progression and story continuity
3. **Context Depth** - Use FULL TEXT (not just last 3 lines) for analysis
4. **Multi-line Coherence** - Story progression across the 4 suggested lines (build a mini-story)
5. **Musical Constraints** - Better syllable stress matching, flow patterns, beat alignment
6. **Style/Voice Detection** - Detect user's style from full text and match it in suggestions
7. **Confidence Scoring** - Require AI to score confidence based on how well suggestions match ALL constraints

## Current State Analysis

åThe API has two main prompts:

1. **Narrative Analysis** (`analyzeNarrative`) - Currently uses full text but analysis could be deeper
2. **Suggestion Generation** (`generateSuggestions`) - Uses only last 3 lines, has basic rules

Key constraints:

- Only uses last 3 lines for generation context (line 169)
- Basic rules about themes, tone, syllables
- No explicit story progression requirements
- Limited musical/rhythm constraints

## Proposed Improvements

### 1. Enhanced Narrative Analysis Prompt

**Location**: `analyzeNarrative()` function, lines 45-64

**Changes**:

- Add explicit instructions to analyze narrative progression
- Extract story elements (characters, setting, conflict, resolution)
- Identify what the next lines should accomplish narratively
- Extract key phrases/concepts that should be referenced for continuity
- Detect narrative momentum (building, resolving, maintaining)

**Enhanced extraction**:

- Better detection of narrative phase based on full text
- Identify story elements that should be referenced/continued
- Extract key phrases/concepts from the full verse
- Detect if verse is building tension, resolving, or maintaining momentum

### 2. Enhanced Generation Prompt - Full Text Context

**Location**: `generateSuggestions()` function, lines 165-208

**Major Changes**:

#### A. Context Enhancement (HIGH IMPACT)

- **Use full text** instead of just last 3 lines
- Include full verse context in the prompt
- Add structured context sections:
- Full verse (for narrative continuity)
- Last 4-6 lines (immediate context)
- Key thematic elements extracted from full text
- Story elements that should be referenced

#### B. Story Progression Rules (NEW - HIGH IMPACT)

Add explicit rules for 4-line story progression:

1. **Line-by-line narrative arc**:

- Line 1: Should continue/bridge from user's last line
- Line 2: Should develop/expand the idea
- Line 3: Should build momentum/raise stakes
- Line 4: Should provide a strong ending/punchline/setup for next lines

2. **Progressive escalation**: Each line should add something new (information, emotion, intensity)
3. **Cohesive mini-story**: All 4 lines should work together as a complete thought/story unit
4. **Reference continuity**: Reference entities, objects, or concepts from the full verse when appropriate

#### C. Thematic Consistency Rules (ENHANCED)

1. Must maintain ALL primary themes throughout the 4-line suggestion
2. Secondary themes should appear naturally
3. Avoid introducing new themes unless they naturally extend existing ones
4. Reject suggestions that contradict established themes
5. Use key phrases/concepts from the full verse when appropriate

#### D. Narrative Flow Rules (ENHANCED)

1. Build logically on the FULL verse context, not just last lines
2. Narrative phase awareness:

- "build" → escalate tension/energy across the 4 lines
- "climax" → maintain intensity, add resolution elements
- "outro" → provide resolution or conclusion
- "verse" → continue narrative progression

3. Reference entities/objects from the full text when relevant
4. Maintain perspective consistency (first-person vs third-person)
5. Maintain temporal/logical consistency with full verse

#### E. Musical Constraints Rules (NEW - HIGH IMPACT)

1. **Syllable stress patterns**:

- Match stress patterns of user's lines when possible
- Maintain rhythmic consistency
- Use stress pattern analysis from cadence metrics

2. **Flow patterns**:

- Maintain consistent syllable variance (from cadence analysis)
- Match flow style (dense vs sparse, fast vs slow)

3. **Rhythm consistency**:

- Lines should have similar rhythm/pace as user's lines
- Avoid jarring rhythm shifts within the 4-line suggestion

4. **Beat alignment considerations**:

- Consider how lines would flow over a beat
- Maintain groove/feel consistency

#### F. Multi-line Coherence Rules (NEW - HIGH IMPACT)

1. **Inter-line coherence**: Each line must flow naturally into the next
2. **Complete thought**: The 4 lines should form a complete, coherent thought/story
3. **Avoid fragmentation**: Don't create 4 disconnected lines
4. **Punctuation/flow**: Use appropriate line breaks and phrasing
5. **Emotional progression**: Build emotional momentum across the 4 lines

### 3. System Message Enhancement

**Location**: `generateSuggestions()` function, line 215

**Change**: Make system message emphasize:

- Narrative continuity and story progression
- Full context awareness
- Multi-line coherence requirements
- Musical/rhythm constraints

### 4. Style/Voice Detection (NEW - HIGH IMPACT)

**Location**: `analyzeNarrative()` function

**Implementation**:

- Add style detection to narrative analysis
- Extract style characteristics from full text:
- Vocabulary complexity (simple vs complex words)
- Sentence structure (short punchy lines vs longer flowing lines)
- Figurative language usage (metaphors, similes, imagery)
- Aggressiveness/energy level
- Formality level (street slang vs formal language)
- Repetition patterns
- Punctuation style

**Add to NarrativeAnalysis struct** (or extract in analysis):

- `styleCharacteristics`: Dictionary/object with style traits
- Or add fields like: `vocabularyLevel`, `energyLevel`, `formalityLevel`, etc.

**Usage in generation prompt**:

- Include style characteristics in context
- Require suggestions to match user's detected style
- Rules: "Match the user's style: [style characteristics]"

### 5. Enhanced Confidence Scoring (NEW - HIGH IMPACT)

**Location**: `generateSuggestions()` function, JSON response structure

**Current state**: Confidence is provided but rules for scoring are minimal

**Implementation**:

- Add explicit instructions for confidence scoring
- Require AI to score based on:

1. Theme matching (0-1.0 weight)
2. Narrative flow/coherence (0-1.0 weight)
3. Multi-line coherence (0-1.0 weight)
4. Musical constraints (syllables, rhyme, flow) (0-1.0 weight)
5. Style matching (0-1.0 weight)
6. Story progression quality (0-1.0 weight)

- Confidence = weighted average or minimum of all constraint scores
- Instructions: "Score confidence 0.0-1.0 based on how well the suggestion matches ALL constraints. Lower confidence if any constraint is weak."

**Rules to add**:

- Confidence should reflect how well the suggestion matches ALL requirements
- If a suggestion violates any major constraint, confidence should be low
- Higher confidence = better overall match across all dimensions

### 6. Additional High-Impact Recommendations (Future Considerations)

#### A. Stress Pattern Analysis (HIGH IMPACT - NOT YET IMPLEMENTED)

- Extract stress patterns from user's lines
- Pass stress patterns to API
- Require suggestions to match stress patterns
- This would require adding stress pattern extraction to RapAnalysisEngine

#### B. Candidate Filtering Enhancement (MEDIUM IMPACT)

- The ConstraintFilter already exists but could be enhanced
- Could add story coherence scoring
- Could add theme matching scoring (currently semantic score is placeholder)
- Could add style matching scoring

#### C. Post-Processing Validation (MEDIUM IMPACT)

- Add validation that 4-line suggestions actually form coherent stories
- Could use a secondary API call for validation
- Or add programmatic checks for coherence

## Implementation Details

### Files to Modify

1. **`[XJournal AI/RapSuggestionAPI.swift](XJournal AI/RapSuggestionAPI.swift)`**:

- Update `generateSuggestions()` prompt (lines 165-208)
- Add full text context
- Add style matching requirements
- Add enhanced confidence scoring instructions
- Add all new rules (story progression, coherence, etc.)
- Update system message (line 215)
- Update `analyzeNarrative()` prompt (lines 45-64)
- Add style detection instructions
- Enhance narrative progression extraction

2. **`[XJournal AI/RapAnalysisEngine.swift](XJournal AI/RapAnalysisEngine.swift)`** (Optional Enhancement):

- Consider extracting more context (last 4-6 lines, key lines)
- Could add stress pattern extraction (future enhancement)

### Prompt Structure Changes

**Current prompt structure**:

- User's current verse: Last 3 lines only
- Context: Basic metrics
- Rules: Basic constraints

**New prompt structure**:

- Full verse context: Complete text for narrative continuity
- Last 4-6 lines: Immediate context (for flow)
- Extracted narrative elements: Story elements, key phrases, themes
- Context: Enhanced metrics + narrative analysis
- Rules: Comprehensive constraints for story progression, coherence, themes, musical constraints

### Temperature Adjustment

Consider adjusting temperature:

- Current: 0.7
- Recommendation: 0.6-0.65 for more consistent, coherent results while maintaining creativity

## Testing Considerations

- Test with various narrative phases (intro, build, climax, outro)
- Test thematic consistency across different themes
- Verify 4-line suggestions form cohesive mini-stories
- Test with long verses (full context usage)
- Verify narrative flow feels natural and progressive
- Test musical constraints (rhythm, flow consistency)
- Ensure suggestions don't contradict user's established story elements

## Future Enhancements (Not in Current Scope)

1. Stress pattern extraction and matching
2. Enhanced candidate filtering with story coherence scoring
3. Post-processing validation of suggestions
4. Style/voice consistency detection
5. Beat/rhythm pattern analysis