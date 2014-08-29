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

from django import forms
from django.utils.translation import ugettext_lazy as _


from datetimewidget.widgets import DateTimeWidget


class CDRSearchForm(forms.Form):
    """VoIP call Report Search Parameters"""
    dateTimeOptions = {
        'format': 'yyyy-dd-mm hh:ii',
        'todayBtn': 'true',
        'usetz': 'true',
        'usel10n': 'true',
        'usei18n': 'true'
    }
    from_date = forms.CharField(label=_('From'), required=False, max_length=20,
        widget=DateTimeWidget(options=dateTimeOptions))
    to_date = forms.CharField(label=_('To'), required=False, max_length=20,
        widget=DateTimeWidget(options=dateTimeOptions))
    dest_num = forms.IntegerField(label=_('Destination Number'), required=False,
        help_text=_('Enter the full number or the first part'))