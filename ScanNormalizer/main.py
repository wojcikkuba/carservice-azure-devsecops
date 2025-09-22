import re
from collections import Counter, defaultdict

SEVERITY_MAP = {
    "CRITICAL": 10,
    "HIGH": 7,
    "MEDIUM": 5,
    "LOW": 3,
    "INFO": 1
}

def parse_kics(filename):
    counts = Counter()
    with open(filename, encoding="utf-8") as f:
        for line in f:
            for sev in SEVERITY_MAP.keys():
                if f"Severity: {sev}" in line:
                    counts[sev] += 1
    return counts

def parse_trivy(filename):
    counts = Counter()
    with open(filename, encoding="utf-8") as f:
        for line in f:
            for sev in SEVERITY_MAP.keys():
                if f"({sev})" in line:
                    counts[sev] += 1
    return counts

def parse_checkov(filename):
    counts = Counter()
    with open(filename, encoding="utf-8") as f:
        for line in f:
            if "FAILED" in line:
                match = re.search(r"(CRITICAL|HIGH|MEDIUM|LOW|INFO)", line, re.IGNORECASE)
                if match:
                    counts[match.group(1).upper()] += 1
                else:
                    counts["MEDIUM"] += 1
    return counts

def calculate_metrics(counts):
    total_points = sum(SEVERITY_MAP[sev] * num for sev, num in counts.items())
    total_findings = sum(counts.values())
    avg_weight = total_points / total_findings if total_findings else 0
    return total_points, avg_weight, dict(counts)

files = {
    "KICS": "../kics.txt",
    "Trivy": "../trivy.txt",
    "Checkov": "../checkov.txt"
}

results = {}
for tool, fname in files.items():
    if tool == "KICS":
        counts = parse_kics(fname)
    elif tool == "Trivy":
        counts = parse_trivy(fname)
    else:
        counts = parse_checkov(fname)
    score, avg, breakdown = calculate_metrics(counts)
    results[tool] = {
        "score": score,
        "avg": avg,
        "breakdown": breakdown
    }

# Raport
for tool, data in results.items():
    print(f"\n=== {tool} ===")
    print(f"Risk score: {data['score']}")
    print(f"Średnia waga błędu: {data['avg']:.2f}")
    print("Rozkład:", data["breakdown"])
