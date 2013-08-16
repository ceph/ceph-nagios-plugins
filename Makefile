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
#     Valery Tschopp  <valery.tschopp@switch.ch>

name = nagios-plugins-ceph

version = 1.0
release = 1

# configure like options
prefix = /usr/local/nagios
libexecdir = $(prefix)/libexecdir

tmp_dir = $(CURDIR)/tmp

.PHONY: clean dist install

clean:
	rm -rf $(tmp_dir) *.tar.gz

dist:
	@echo "Packaging sources"
	test ! -d $(tmp_dir) || rm -fr $(tmp_dir)
	mkdir -p $(tmp_dir)/$(name)-$(version)
	cp Makefile $(tmp_dir)/$(name)-$(version)
	cp COPYRIGHT LICENSE README.md CHANGELOG $(tmp_dir)/$(name)-$(version)
	cp -r src $(tmp_dir)/$(name)-$(version)
	test ! -f $(name)-$(version).tar.gz || rm $(name)-$(version).tar.gz
	tar -C $(tmp_dir) -czf $(name)-$(version).tar.gz $(name)-$(version)
	rm -fr $(tmp_dir)


install:
	@echo "Installing Ceph Nagios plugins in $(DESTDIR)$(libexecdir)..."
	install -d $(DESTDIR)$(libexecdir)
	install -m 0755 src/* $(DESTDIR)$(libexecdir)

