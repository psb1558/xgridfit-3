import os
from setuptools import setup, find_packages

exec(open('xgridfit/version.py').read())

setup (
    name = "xgridfit",
    version = __version__,
    packages = find_packages(),
    entry_points={
        "console_scripts": ["xgridfit = xgridfit:main"]
    },
    install_requires = ["fonttools", "lxml", "setuptools"],
    include_package_data=True,
    package_data={"": ["XSL/*.xsl", "XSL/*.xml", "Schemas/*.rnc", "Schemas/*.rng",
                       "Schemas/*.xsd"]}
)
