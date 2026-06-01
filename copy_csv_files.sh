#!/bin/bash

# Script to copy CSV files from Desktop to XJournal AI directory
# Run this script to copy the required CSV files into the app

SOURCE_DIR="$HOME/Desktop"
DEST_DIR="$HOME/Documents/The Final Journal AI/XJournal AI"

echo "📋 Copying CSV files from Desktop to XJournal AI directory..."

# File 1: Editorial Ground Truth Rap Bars
if [ -f "$SOURCE_DIR/editorial_ground_truth_rap_bars jan 26.csv" ]; then
    cp "$SOURCE_DIR/editorial_ground_truth_rap_bars jan 26.csv" "$DEST_DIR/"
    echo "✅ Copied: editorial_ground_truth_rap_bars jan 26.csv"
elif [ -f "$SOURCE_DIR/editorial_ground_truth_rap_bars jan 26" ]; then
    cp "$SOURCE_DIR/editorial_ground_truth_rap_bars jan 26" "$DEST_DIR/editorial_ground_truth_rap_bars jan 26.csv"
    echo "✅ Copied: editorial_ground_truth_rap_bars jan 26 (added .csv extension)"
else
    echo "⚠️  Not found: editorial_ground_truth_rap_bars jan 26"
fi

# File 2: Jargon Authority Lexicon
if [ -f "$SOURCE_DIR/jargon_Authority_Lexicon_restored_context_v2.csv" ]; then
    cp "$SOURCE_DIR/jargon_Authority_Lexicon_restored_context_v2.csv" "$DEST_DIR/"
    echo "✅ Copied: jargon_Authority_Lexicon_restored_context_v2.csv"
else
    echo "⚠️  Not found: jargon_Authority_Lexicon_restored_context_v2.csv"
fi

# File 3: Theme CSV
if [ -f "$SOURCE_DIR/2.0 THEME_CSV_AI_BRAIN_with_THEME_ID.csv" ]; then
    cp "$SOURCE_DIR/2.0 THEME_CSV_AI_BRAIN_with_THEME_ID.csv" "$DEST_DIR/"
    echo "✅ Copied: 2.0 THEME_CSV_AI_BRAIN_with_THEME_ID.csv"
else
    echo "⚠️  Not found: 2.0 THEME_CSV_AI_BRAIN_with_THEME_ID.csv"
fi

echo ""
echo "📁 Files are now in: $DEST_DIR"
echo "💡 Make sure to add these files to your Xcode project target!"
