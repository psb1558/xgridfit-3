import os
from setuptools import setup, find_packages

setup (
    name = "xgridfit",
    version = "3.0",
    packages = find_packages(),
    entry_points={
        "console_scripts": ["xgridfit = xgridfit:main"]
    },
    install_requires = ["fonttools", "lxml"],
    include_package_data=True,
    package_data={"": ["XSL/*.xsl", "XSL/*.xml", "Schemas/*.rnc", "Schemas/*.rng",
                       "Schemas/*.xsd"]}
)
