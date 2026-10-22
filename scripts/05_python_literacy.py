# Question 5: Reproduce weighted literacy rates in Python
# Registration: FA24-BEDS-086
# Assigned group: Balochistan Rural

from pathlib import Path
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Locate the project folder
project_dir = Path(__file__).resolve().parent.parent

# Read PSLM datasets
hh = pd.read_csv(project_dir / "data" / "pslm_hh_subset.csv")
person = pd.read_csv(project_dir / "data" / "pslm_person_subset.csv")

# Join household information to person records
pslm = person.merge(
    hh[["hhid", "hhweight", "prov_code", "urban_rural"]],
    on="hhid",
    how="left"
)

# Select Balochistan Rural and valid literacy observations
data = pslm[
    (pslm["prov_code"] == 4) &
    (pslm["urban_rural"] == 1) &
    (pslm["age"].between(10, 64)) &
    (pslm["sex"].isin([1, 2])) &
    (pslm["literate"].isin([0, 1])) &
    (pslm["hhweight"].notna()) &
    (pslm["hhweight"] > 0)
].copy()

# Create five-year age bands
data["age_start"] = 10 + 5 * ((data["age"] - 10) // 5)
data["age_band"] = (
    data["age_start"].astype(int).astype(str)
    + "-"
    + (data["age_start"] + 4).astype(int).astype(str)
)
data["sex_label"] = data["sex"].map({1: "Male", 2: "Female"})

# Calculate household-weighted literacy rates
data["weighted_literate"] = data["literate"] * data["hhweight"]

results = (
    data.groupby(["age_start", "age_band", "sex_label"])
    .agg(
        n=("literate", "size"),
        weighted_sum=("weighted_literate", "sum"),
        total_weight=("hhweight", "sum")
    )
    .reset_index()
)

results["literacy_rate"] = (
    100 * results["weighted_sum"] / results["total_weight"]
)

# Display results rounded to one decimal place
results = results.sort_values(["age_start", "sex_label"])

print("\nQUESTION 5: PYTHON WEIGHTED LITERACY RATES\n")
print(
    results[["age_band", "sex_label", "n", "literacy_rate"]]
    .to_string(
        index=False,
        formatters={"literacy_rate": "{:.1f}".format}
    )
)

# Save results for comparison with R
output = project_dir / "data" / "05_python_literacy_results.csv"
results[["age_band", "sex_label", "n", "literacy_rate"]].to_csv(
    output, index=False
)

print("\nResults saved to:", output)


# Question 5: Python literacy graph

fig, ax = plt.subplots(figsize=(10, 6))

for sex, color in [("Female", "tomato"), ("Male", "teal")]:
    group = results[results["sex_label"] == sex].sort_values("age_start")

    ax.plot(
        group["age_start"] + 2,
        group["literacy_rate"],
        marker="o",
        linewidth=2,
        label=sex,
        color=color
    )

ax.set_title("Literacy Rates by Age and Sex — Balochistan Rural")
ax.set_xlabel("Age group midpoint")
ax.set_ylabel("Weighted literacy rate (%)")
ax.set_xticks(range(12, 63, 5))
ax.set_ylim(0, 100)
ax.grid(alpha=0.25)
ax.legend(title="Sex")

fig.tight_layout()

output_graph = project_dir / "figures" / "05_python_literacy.svg"
fig.savefig(output_graph, format="svg")
plt.close(fig)

print("Python graph saved to:", output_graph)