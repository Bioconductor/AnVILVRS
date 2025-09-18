from plugin_system.plugin_manager import PluginManager
from vrs_anvil.evidence import get_cohort_allele_frequency
import subprocess

def initialize_plugin(plugin_name: str, **kwargs):
    """
    Loads and initializes a specific plugin.
    This is a one-time setup function.
    
    Args:
        plugin_name (str): The name of the plugin class to load.
        **kwargs: Optional arguments to pass to the plugin's constructor.
                  (e.g., phenotype_table_path for ThousandGenomesPlugin)

    Returns:
        An initialized plugin object.
    """
    print(f"Initializing plugin: {plugin_name}...")
    try:
        plugin_class = PluginManager().load_plugin(plugin_name)
        # Instantiate the class with any provided keyword arguments
        plugin_instance = plugin_class(**kwargs)
        print("Plugin initialized successfully!")
        return plugin_instance
    except OSError as e:
        print(f"Error: Could not load plugin '{plugin_name}'.")
        raise e

def calculate_caf(vrs_id: str, vcf_path: str, vcf_index_path: str, phenotype: str, plugin_object):
    """
    Calculates the cohort allele frequency using a pre-initialized plugin object.
    
    Args:
        vrs_id (str): The variant ID.
        vcf_path (str): Path to the VCF file.
        vcf_index_path (str): Path to the VCF index database.
        phenotype (str): The phenotype or population to query.
        plugin_object: A pre-initialized plugin object from initialize_plugin().

    Returns:
        A dictionary containing the CAF data.
    """
    # Run the prerequisite vrsix command with better error handling
    command = ["vrsix", "load", f"--db-location={vcf_index_path}", vcf_path]
    try:
        subprocess.run(command, check=True, text=True, capture_output=True)
    except subprocess.CalledProcessError as e:
        # If the command fails, raise an exception to stop execution
        raise RuntimeError(f"Error executing vrsix command: {e.stderr}") from e
        
    # Calculate the frequency
    caf_object = get_cohort_allele_frequency(
        variant_id=vrs_id,
        vcf_path=vcf_path,
        vcf_index_path=vcf_index_path,
        plugin=plugin_object,
        phenotype=phenotype,
    )

    # Return the data as a dictionary instead of printing it
    return caf_object.model_dump(exclude_none=True)
