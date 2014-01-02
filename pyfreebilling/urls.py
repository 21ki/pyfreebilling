# Copyright 2013 Mathias WOLFF
# This file is part of pyfreebilling.
#
# pyfreebilling is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# pyfreebilling is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with pyfreebilling.  If not, see <http://www.gnu.org/licenses/>

from django.conf.urls import patterns, include, url
from django.contrib import admin
from django.http import HttpResponseRedirect
from yawdadmin import admin_site

#from adminactions import actions
#import adminactions.urls

#from pyfreebill.urls import urlpatterns as pyfreebill_url
from django.core.urlresolvers import reverse, reverse_lazy, resolve

admin.autodiscover()
admin_site._registry.update(admin.site._registry)
#actions.add_to_site(admin_site)

# Custom menu
def perms_func(request, item):
        if not request.user.is_superuser and item['name'].startswith('Statistics'):
                return False
        return True
        
        
admin_site.register_top_menu_item('1_Customers', icon_class="icon-user",
        children=[
            {'name': 'Customers list', 'admin_url': '/extranet/pyfreebill/company/?customer_enabled__exact=1', 'order': 1, 'title_icon': 'icon-list' },
            {'name': 'SIP accounts', 'admin_url': '/extranet/pyfreebill/customerdirectory/', 'order': 2, 'separator': True, 'title_icon': 'icon-check' },
            {'name': 'Tarif groups', 'admin_url': '/extranet/pyfreebill/ratecard/', 'order': 3, 'separator': True, 'title_icon': 'icon-money' },
            {'name': 'rates', 'admin_url': '/extranet/pyfreebill/customerrates/', 'order': 4, 'title_icon': 'icon-money' },
            {'name': 'Destination number normalization', 'admin_url': '/extranet/pyfreebill/customernormalizationrules/', 'order': 4, 'separator': True, 'title_icon': 'icon-medkit' },
            {'name': 'CallerID normalization', 'admin_url': '/extranet/pyfreebill/customercidnormalizationrules/', 'order': 5, 'title_icon': 'icon-medkit' },
            {'name': 'Statistics', 'admin_url': '/extranet/pyfreebill/cdr/', 'order': 6, 'separator': True, 'title_icon': 'icon-dashboard' },            
            ],
        perms=perms_func)

admin_site.register_top_menu_item('2_Providers', icon_class="icon-group",
        children=[
            {'name': 'Providers list', 'admin_url': '/extranet/pyfreebill/company/?supplier_enabled__exact=1', 'order': 1, 'title_icon': 'icon-list' },
            {'name': 'Provider gateways', 'admin_url': '/extranet/pyfreebill/sofiagateway/', 'order': 2, 'separator': True, 'title_icon': 'icon-check' },
            {'name': 'Tarif groups', 'admin_url': '/extranet/pyfreebill/providertariff/', 'order': 3, 'separator': True, 'title_icon': 'icon-money' },
            {'name': 'rates', 'admin_url': '/extranet/pyfreebill/providerrates/', 'order': 4, 'title_icon': 'icon-money' },
            {'name': 'Destination number normalization', 'admin_url': '/extranet/pyfreebill/carriernormalizationrules/', 'order': 4, 'separator': True, 'title_icon': 'icon-medkit' },
            {'name': 'CallerID normalization', 'admin_url': '/extranet/pyfreebill/carriercidnormalizationrules/', 'order': 5, 'title_icon': 'icon-medkit' },
            {'name': 'Statistics', 'admin_url': '/extranet/pyfreebill/cdr/', 'order': 5, 'separator': True, 'title_icon': 'icon-dashboard' },
            ],
        perms=perms_func)

admin_site.register_top_menu_item('3_Routing', icon_class="icon-exchange",
        children=[
            {'name': 'LCR', 'admin_url': '/extranet/pyfreebill/lcrgroup/', 'order': 1, 'title_icon': 'icon-random' },
            {'name': 'Destination Number Normalization', 'admin_url': '/extranet/pyfreebill/destinationnumberrules/', 'order': 2, 'separator': True, 'title_icon': 'icon-medkit' },
            {'name': 'CallerID prefix management', 'admin_url': '/extranet/pyfreebill/calleridprefixlist/', 'order': 3, 'separator': True, 'title_icon': 'icon-list' },
            ],
        perms=perms_func)

admin_site.register_top_menu_item('4_FreeSwitch', icon_class="icon-cogs",
        children=[
            {'name': 'Customer accounts', 'admin_url': '/extranet/pyfreebill/customerdirectory/', 'order': 1, 'title_icon': 'icon-list' },
            {'name': 'Provider gateways', 'admin_url': '/extranet/pyfreebill/sofiagateway/', 'order': 2, 'title_icon': 'icon-list' },
            {'name': 'Freeswitch status', 'admin_url': '/extranet/pyfreebill/sofiagateway/', 'order': 3, 'separator': True, 'title_icon': 'icon-user-md' },
            {'name': 'Freeswitch list', 'admin_url': '/extranet/switch/voipswitch/', 'order': 4, 'title_icon': 'icon-list' },
            {'name': 'Sofia profiles', 'admin_url': '/extranet/pyfreebill/sipprofile/', 'order': 5, 'separator': True, 'title_icon': 'icon-cogs' },
            ],
        perms=perms_func)

admin_site.register_top_menu_item('5_Finance', icon_class="icon-money",
        children=[
            {'name': 'Add payment', 'admin_url': '/extranet/pyfreebill/companybalancehistory/add/', 'order': 1, 'title_icon': 'icon-download-alt' },
            {'name': 'History', 'admin_url': '/extranet/pyfreebill/companybalancehistory/', 'order': 2, 'title_icon': 'icon-money' },
            ],
        perms=perms_func)

admin_site.register_top_menu_item('6_Report', icon_class="icon-dashboard",
        children=[
            {'name': 'CDR', 'admin_url': '/extranet/pyfreebill/cdr/', 'order': 1, 'title_icon': 'icon-phone' },
            {'name': 'Customer stats', 'admin_url': '/extranet/report/', 'order': 2, 'separator': True, 'title_icon': 'icon-dashboard' },
            {'name': 'Provider stats', 'admin_url': '/extranet/pyfreebill/cdr/', 'order': 3, 'title_icon': 'icon-dashboard' },
            ],
        perms=perms_func)

admin_site.register_top_menu_item('7_Admin', icon_class="icon-wrench",
        children=[
            {'name': 'Users', 'admin_url': '/extranet/auth/user/', 'order': 1, 'title_icon': 'icon-user' },
            {'name': 'Access logs', 'admin_url': '/extranet/axes/accesslog/', 'order': 2, 'separator': True, 'title_icon': 'icon-key' },
            {'name': 'Access attempts', 'admin_url': '/extranet/axes/accessattempt/', 'order': 3, 'title_icon': 'icon-warning-sign' },
            {'name': 'Admin logs', 'admin_url': '/extranet/admin/logentry/', 'order': 4, 'separator': True, 'title_icon': 'icon-exclamation-sign' },
            {'name': 'Recurring task logs', 'admin_url': '/extranet/chroniker/log/', 'order': 5, 'title_icon': 'icon-puzzle-piece' },
            {'name': 'Version', 'admin_url': '/extranet/status/', 'order': 6, 'separator': True, 'title_icon': 'icon-pushpin' },
            ],
        perms=perms_func)

# def index(request):
#     return HttpResponseRedirect('/extranet/')

urlpatterns = patterns('',
    url(r'^extranet/report/$', 'pyfreebill.views.admin_report_view'),
    url(r'^extranet/live/$', 'pyfreebill.views.live_report_view'),
    url(r'^extranet/status/$', 'pyfreebill.views.admin_status_view'),
    url(r'^admin/', include('admin_honeypot.urls')),
    url(r'^extranet/', include(admin_site.urls)),
#    url(r'^adminactions/', include(adminactions.urls)),
#    url(r'^elfinder/', include('elfinder.urls')),
)

# Modules
#urlpatterns += pyfreebill_url