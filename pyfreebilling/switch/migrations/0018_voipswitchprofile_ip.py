# -*- coding: utf-8 -*-
# Generated by Django 1.9.12 on 2016-12-20 14:28
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('switch', '0017_auto_20161215_1830'),
    ]

    operations = [
        migrations.AddField(
            model_name='voipswitchprofile',
            name='ip',
            field=models.CharField(default=b'auto', help_text='Sofia context IP address.', max_length=100, verbose_name='context IP'),
        ),
    ]
