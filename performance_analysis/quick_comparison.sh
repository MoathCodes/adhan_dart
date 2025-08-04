#!/bin/bash

# 🚀 Quick Performance Comparison Script
# This script demonstrates the performance improvements between pub.dev and local versions

echo "🧪 Adhan Dart Performance Comparison"
echo "====================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📊 Running pub.dev version benchmark..."
cd "$SCRIPT_DIR/benchmark_pubdev"
dart run lib/benchmark_pubdev.dart | tee pubdev_results.txt

echo ""
echo "📊 Running local enhanced version benchmark..."
cd "$SCRIPT_DIR"
dart run benchmark_local.dart | tee local_results.txt

echo ""
echo "📈 QUICK COMPARISON:"
echo "==================="

# Extract and compare key metrics
pubdev_basic=$(grep "Average time:" pubdev_results.txt | head -1 | awk '{print $3}' | sed 's/μs//g')
local_basic=$(grep "Average time:" local_results.txt | head -1 | awk '{print $3}' | sed 's/μs//g')

pubdev_repeated=$(grep "Average time:" pubdev_results.txt | tail -1 | awk '{print $3}' | sed 's/μs//g')
local_repeated=$(grep "Average time:" local_results.txt | sed -n '2p' | awk '{print $3}' | sed 's/μs//g')

echo "🏆 Basic Calculations:"
echo "   Pub.dev: ${pubdev_basic}μs"
echo "   Local:   ${local_basic}μs"

if command -v bc &> /dev/null && [[ -n "$pubdev_basic" && -n "$local_basic" ]]; then
    improvement=$(echo "scale=0; (($pubdev_basic - $local_basic) / $pubdev_basic) * 100" | bc)
    echo "   🚀 LOCAL IS ${improvement}% FASTER!"
fi

echo ""
echo "🔄 Repeated Calculations:"
echo "   Pub.dev: ${pubdev_repeated}μs"
echo "   Local:   ${local_repeated}μs"

if command -v bc &> /dev/null && [[ -n "$pubdev_repeated" && -n "$local_repeated" ]]; then
    improvement=$(echo "scale=0; (($pubdev_repeated - $local_repeated) / $pubdev_repeated) * 100" | bc)
    echo "   🚀 LOCAL IS ${improvement}% FASTER! (caching benefits)"
fi

echo ""
echo "📄 Detailed comparison available in: PUBDEV_VS_LOCAL_COMPARISON.md"
echo "🎯 Run this script anytime to verify improvements!"
