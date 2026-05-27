from utils import *
from plotnine import *
import pandas as pd


types = ["ECOLI", "SENTERICA", "HUMANGUT"]
values = [12.078, 8.948, 22.725]


# Sample data
df = pd.DataFrame({
    "category": types,
    "value": values
})

df["value_label"] = df["value"].apply(lambda x: f"{x} %")

plot = (
    ggplot(df, aes(x='category', y='value', fill='types')) +
    geom_col(position='dodge') +
    # Add markers for capped values
    geom_text(
        mapping=aes(label='value_label'),
        position=position_dodge(width=0.9),
        size=8,
        fontweight="semibold",
        va='bottom'
    ) +
    scale_y_continuous(limits=(0, 100)) +
    scale_fill_manual(palette_3) +
    theme_light() +
    labs(x='Dataset', y='Density (%)', fill="Dataset", color="Dataset")
)

save_as_pdf_pages([plot + theme(figure_size=FIG_SIZE)], "./figures/density.pdf")