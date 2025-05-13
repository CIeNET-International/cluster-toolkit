import io
import json
import numpy as np
import Bio
from Bio.PDB.MMCIFParser import MMCIFParser
from Bio.PDB.Structure import Structure
import py3Dmol
from IPython.display import display, Markdown
import plotly.express as px
import pandas as pd
from typing import Dict, Tuple, List


def plot_pae_matrix(pae: Dict, token_chain_ids: str) -> None:
    df = pd.DataFrame(pae)
    fig = px.imshow(df, color_continuous_scale='Viridis',
                    labels={'color': 'PAE'},
                    title='Predicted Aligned Error (PAE) Matrix')
    # Draw chain boundaries if available
    if token_chain_ids:
        chain_boundaries = []
        prev_chain = token_chain_ids[0]
        for idx, chain_id in enumerate(token_chain_ids):
            if chain_id != prev_chain:
                chain_boundaries.append(idx - 0.5)
                prev_chain = chain_id

        for boundary in chain_boundaries:
            fig.add_shape(
                type="line",
                x0=boundary,
                y0=0,
                x1=boundary,
                y1=len(token_chain_ids),
                line=dict(color="red", width=1)
            )
            fig.add_shape(
                type="line",
                x0=0,
                y0=boundary,
                x1=len(token_chain_ids),
                y1=boundary,
                line=dict(color="red", width=1)
            )
    fig.update_layout(autosize=True)
    fig.show()


def read_cif_file(file_path: str) -> Tuple[Structure, str]:
    parser = MMCIFParser(QUIET=True)
    with open(file_path, 'r') as file:
        content = file.read()
    file_like = io.StringIO(content)
    structure = parser.get_structure('protein', file_like)
    return structure, content


def extract_pae_from_json(file_path: str) -> Tuple[np.array, List]:
    with open(file_path, 'r') as file:
        data = json.load(file)
    pae = np.array(data.get('pae', []), dtype=np.float16)
    token_chain_ids = data.get('token_chain_ids', [])
    return pae, token_chain_ids


def show_structure_3d(cif_string: str, width=500, height=400) -> None:
    viewer = py3Dmol.view(width=width, height=height)
    viewer.addModel(cif_string, 'cif')
    viewer.setStyle({'cartoon': {'color': 'spectrum'}})
    viewer.zoomTo()
    viewer.show()
    display(viewer)


def extract_summary_confidences_obj(file_path: str) -> Dict:
    """Extract summary confidence data from JSON file object."""
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            data = json.load(f)
        # Check if data is a list
        if isinstance(data, list):
            summary_data = data[0]  # Take first element if it's a list
        else:
            summary_data = data

        # Convert any numpy arrays to lists for JSON serialization
        processed_data = {}
        for key, value in summary_data.items():
            if isinstance(value, np.ndarray):
                processed_data[key] = value.tolist()
            else:
                processed_data[key] = value

        return processed_data
    except Exception as e:
        print(f"Error extracting summary confidence data: {str(e)}")
        return {}  # Return empty dict as fallback


def display_summary_data(summary_data: Dict, chain_ids: List) -> None:
    display(Markdown("### Summary of Confidence Metrics"))

    # Map chain-level metrics to chain IDs
    chain_metrics = {}
    for key in ['chain_iptm', 'chain_ptm']:
        if key in summary_data:
            values = summary_data[key]
            if len(values) == len(chain_ids):
                chain_metrics[key] = dict(zip(chain_ids, values))
            else:
                print(
                    f"Warning: The number of values in '{key}' does not match the number of chains.")

    # Optionally print the mapped metrics
    for key, val in chain_metrics.items():
        print(f"\n{key}:")
        for chain_id, metric in val.items():
            print(f"  Chain {chain_id}: {metric}")
