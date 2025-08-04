# 🚀 Performance Analysis Suite

This folder contains all the performance benchmarks and comparison tools for the adhan_dart library enhancements.

## 📁 Contents

### 📊 Comparison Reports
- **`PUBDEV_VS_LOCAL_COMPARISON.md`** - Comprehensive performance comparison between pub.dev and local versions
- **`PERFORMANCE_REPORT.md`** - Detailed technical analysis of all optimizations
- **`FEATURE_SUMMARY.md`** - Complete summary of all improvements made

### 🧪 Benchmark Scripts
- **`quick_comparison.sh`** - One-click script to run both versions and compare results
- **`benchmark_local.dart`** - Benchmark script for the enhanced local version
- **`benchmark_pubdev/`** - Separate project to test against actual pub.dev version

### 📈 Test Results
- **`results_local_final.txt`** - Latest local version benchmark results
- **`results_pubdev_final.txt`** - Latest pub.dev version benchmark results

## 🚀 Quick Start

Run the complete comparison:
```bash
./quick_comparison.sh
```

View the detailed analysis:
```bash
cat PUBDEV_VS_LOCAL_COMPARISON.md
```

## 🏆 Key Results

- **45% faster basic calculations** (184.4μs → 101.4μs)
- **41% faster repeated calculations** (68.8μs → 40.3μs)  
- **84% higher throughput** (5,435 → 10,000 calculations/second)
- **19% better memory efficiency** (65.7μs → 52.9μs per object)
