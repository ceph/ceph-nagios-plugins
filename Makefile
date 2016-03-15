# Copyright (c) 2013 SWITCH http://www.switch.ch
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Authors:
#     Valery Tschopp <valery.tschopp@switch.ch>
#     Ricardo Rocha <ricardo@catalyst.net.nz>

name = nagios-plugins-ceph
version = 1.5.0

# install options (like configure)
# ex: make sysconfdir=/etc libdir=/usr/lib64 sysconfdir=/etc install
prefix = /usr
libdir = $(prefix)/lib
sysconfdir = $(prefix)/etc
nagiosdir = $(libdir)/nagios/plugins
nagiosconfdir = $(sysconfdir)/nagios-plugins/config

tmp_dir = $(CURDIR)/tmp

.PHONY: clean dist install deb deb-src

clean:
	rm -rf $(tmp_dir) *.tar.gz *.deb *.dsc

dist:
	@echo "Packaging sources"
	test ! -d $(tmp_dir) || rm -fr $(tmp_dir)
	mkdir -p $(tmp_dir)/$(name)-$(version)
	cp Makefile $(tmp_dir)/$(name)-$(version)
	cp COPYRIGHT LICENSE README.md CHANGELOG $(tmp_dir)/$(name)-$(version)
	cp -R src $(tmp_dir)/$(name)-$(version)
	cp -R config $(tmp_dir)/$(name)-$(version)
	cp -R debian $(tmp_dir)/$(name)-$(version)
	test ! -f $(name)-$(version).tar.gz || rm $(name)-$(version).tar.gz
	tar -C $(tmp_dir) -czf $(name)-$(version).tar.gz $(name)-$(version)
	rm -fr $(tmp_dir)

install:
	@echo "Installing Ceph Nagios plugins in $(DESTDIR)$(nagiosdir)"
	install -d $(DESTDIR)$(nagiosdir)
	install -m 0755 src/* $(DESTDIR)$(nagiosdir)
	install -d $(DESTDIR)$(nagiosconfdir)
	install -m 0644 config/* $(DESTDIR)$(nagiosconfdir)

pre_deb: dist
	mkdir -p $(tmp_dir)
	cp $(name)-$(version).tar.gz $(tmp_dir)/$(name)_$(version).orig.tar.gz
	tar -C $(tmp_dir) -xzf $(tmp_dir)/$(name)_$(version).orig.tar.gz

deb-src: pre_deb
	@echo "Debian source package..."
	cd $(tmp_dir) && dpkg-source -b $(name)-$(version)
	cp $(tmp_dir)/$(name)_$(version)* .
	rm -rf $(tmp_dir)

deb: pre_deb
	@echo "Debian package..."
	cd $(tmp_dir)/$(name)-$(version) && debuild -uc -us
	cp $(tmp_dir)/$(name)*.deb .
	rm -rf $(tmp_dir)

