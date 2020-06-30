        sh """#!/bin/bash
        	cd ${pipeline_workspace}
       		echo "pipeline_workspace : ${pipeline_workspace}"
		cat <<- EOF > ${pipeline_workspace}/.rpmmacros
			%_topdir       ${pipeline_workspace}/rpm
			%_tmppath      ${pipeline_workspace}/rpm/tmp
		EOF
        	mkdir -p  ${pipeline_workspace}/rpm ${pipeline_workspace}/rpm/BUILD ${pipeline_workspace}/rpm/RPMS ${pipeline_workspace}/rpm/RPMS/noarch ${pipeline_workspace}/rpm/SOURCES ${pipeline_workspace}/rpm/SPECS ${pipeline_workspace}/rpm/SRPM ${pipeline_workspace}/rpm/tmp
          	INSTALL_DIR="/opt/puppet-modules"
          	MODULE_FILE=\$(basename "${compiled_file}")
          	echo "Module File : \${MODULE_FILE}"
          MODULE_DIR=\$(echo "\${MODULE_FILE}" | sed 's/.tar.*//g')
          echo "Module_dir : \${MODULE_DIR}"
          cp ${compiled_file} ${pipeline_workspace}/rpm/SOURCES/
          DESCRIPTION=\$(grep summary "\${MODULE_DIR}/metadata.json" | awk -F: '{print \$2}' | sed 's/,\$//g')
          RPM_PREFIX="puppet_module_${full_module_name}"
          cat <<- EOF > "${pipeline_workspace}/rpm/SPECS/puppet-module-\${RPM_PREFIX}-${module_version}-${release_version}.spec"
		Summary: Locally installs \${RPM_PREFIX} to be used with puppet apply
		Name: \${RPM_PREFIX}
		Version: ${module_version}
		License: Restricted
		Release: ${release_version}
		BuildRoot: %{_builddir}/%{name}-root
		Packager: ${module_author}
		Prefix: \${INSTALL_DIR}
		BuildArchitectures: noarch
		Source1: \${MODULE_FILE}
		%description
		\${DESCRIPTION}
		%prep
		%build
		pwd
		cd %{_sourcedir}
		%install
		pwd
		echo \"Removing RPM Build Root : \\\${RPM_BUILD_ROOT}\"
		rm -rf \\\${RPM_BUILD_ROOT}
		mkdir -p \\\${RPM_BUILD_ROOT}\${INSTALL_DIR}
		tar zxvf %{SOURCE1} --directory=\\\${RPM_BUILD_ROOT}\${INSTALL_DIR}
		mv \\\${RPM_BUILD_ROOT}\${INSTALL_DIR}/\${MODULE_DIR} \\\${RPM_BUILD_ROOT}\${INSTALL_DIR}/${moduleName}
		%clean
		rm -rf \\\${RPM_BUILD_ROOT}
		%files
		%defattr(-,puppet,puppet)
	EOF
	echo "\${INSTALL_DIR}/${moduleName}/" >> "${pipeline_workspace}/rpm/SPECS/puppet-module-\${RPM_PREFIX}-${module_version}-${release_version}.spec"
        rpmbuild --define "_topdir ${pipeline_workspace}/rpm" --define "_tmppath ${pipeline_workspace}/rpm/tmp" -ba "${pipeline_workspace}/rpm/SPECS/puppet-module-\${RPM_PREFIX}-${module_version}-${release_version}.spec"
	built_rpm=${pipeline_workspace}/rpm/RPMS/noarch/\${RPM_PREFIX}-${module_version}-${release_version}.noarch.rpm
        """ 
