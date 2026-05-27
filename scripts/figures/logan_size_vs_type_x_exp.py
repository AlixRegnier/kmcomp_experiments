from utils import *
from plotnine import *
import pandas as pd

exps = ["no compression", "compressed", "π-compressed"]


no_comp = 1023.77
comp = 514.23
picomp = 455.30

        
# Sample data
df = pd.DataFrame({
    "category": exps,
    "category_order": [*range(len(exps))],
    "value": [no_comp, comp, picomp]
})

df['value_label'] = df['value'].apply(lambda x: decimals(x, 1, "TB"))
df['category'] = pd.Categorical(df['category'], categories=df.loc[df['category_order'].sort_values().index, 'category'], ordered=True)

plot = (
    ggplot(df, aes(x='category', y='value', fill='category')) +
    geom_col(position="dodge") +
    geom_text(
        mapping=aes(label='value_label'),
        position=position_dodge(width=0.9),
        size=7,
        fontweight="semibold",
        va='bottom'
    ) +
    scale_fill_manual(palette_logan) +
    theme_light() +
    scale_y_continuous(labels=lambda x: [f"{int(val)} TB" for val in x]) + 
    labs(x='Experiment', y='Logan size (TB)', fill="Experiment", color="Experiment")
)

#plot.show()
save_as_pdf_pages([plot + theme(figure_size=FIG_SIZE)], "./figures/logan_size_vs_type_x_exp.pdf")