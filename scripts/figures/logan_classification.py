from utils import *
from plotnine import *
import pandas as pd

categories = {
    "BCT" : 3.2,
    "ENV" : 0.0,
    "HUMAN" : 25.7,
    "INV" : 14.3,
    "MAM" : 2.8,
    "MICE" : 23.3,
    "PHG" : 0.0,
    "PLN" : 15.2,
    "PRI" : 0.0,
    "ROD" : 0.0,
    "UNKNOWN" : 8.4,
    "VRL" : 0.0,
    "VRT" : 7.1
}

#print(sorted(zip(categories.values(), categories.keys()), reverse=True))

# Sample data
df = pd.DataFrame({
    "category": list(categories.keys()),
    "value": categories.values()
})


plot = (
    ggplot(df, aes(x='reorder(category, -value)', y='value/100')) +
    geom_col(position='dodge') +
    # Add markers for capped values
    scale_fill_identity() + 
    theme_light() +
    #theme(axis_text_x=element_text(rotation=23)) + 
    labs(x='Specie', y='Specie proportion')   
)

save_as_pdf_pages([plot + theme(figure_size=FIG_SIZE)], "./figures/logan_classification.pdf")