from ga4gh.vrs.extras.translator import AlleleTranslator
from ga4gh.vrs.dataproxy import create_dataproxy
import json

seqrepo_rest_service_url = "seqrepo+https://services.genomicmedlab.org/seqrepo"
seqrepo_dataproxy = create_dataproxy(uri=seqrepo_rest_service_url)
allele_translator = AlleleTranslator(data_proxy=seqrepo_dataproxy)

def get_vrs_id_from_variant(variant_id, from_format="gnomad"):
  """
  Translates a variant ID (e.g., in gnomad format) to a VRS Allele ID.
  """
  try:
    allele = allele_translator.translate_from(variant_id, from_format)
    # The VRS ID is accessed via the `id` property, which is a CURIE string
    vrs_id = str(allele.id)
    return vrs_id
  except Exception as e:
    # Return the error message if translation fails
    return str(e)
