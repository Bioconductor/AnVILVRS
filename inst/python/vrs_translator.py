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
    allele = get_vrs_allele_from_variant(variant_id, from_format)
    vrs_id = str(allele.id)
    return vrs_id
  except Exception as e:
    return str(e)

def get_vrs_allele_from_variant(variant_id, from_format="gnomad"):
  """
  Translates a variant ID (e.g., in gnomad format) to a VRS Allele object.
  """
  try:
    allele = allele_translator.translate_from(variant_id, from_format)
    return allele
  except Exception as e:
    return str(e)

def get_variant_from_allele(allele, to_format="gnomad"):
  """
  Translates a VRS Allele object to a variant ID in the specified format (e.g.,
  gnomad).
  """
  try:
    variant_id = allele_translator.translate_to(allele, to_format)
    return variant_id
  except Exception as e:
    return str(e)
