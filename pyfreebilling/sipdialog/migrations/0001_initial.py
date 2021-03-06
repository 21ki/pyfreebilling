# -*- coding: utf-8 -*-
# Generated by Django 1.11.12 on 2018-04-09 17:35
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Dialog',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('hash_entry', models.IntegerField(help_text='Number of the hash entry in the dialog hash table')),
                ('hash_id', models.IntegerField(help_text='The ID on the hash entry')),
                ('callid', models.CharField(help_text='Call-ID of the dialog', max_length=255)),
                ('from_uri', models.CharField(help_text='The URI of the FROM header (as per INVITE)', max_length=128)),
                ('from_tag', models.CharField(help_text='The tag parameter serves as a general mechanism to identify a dialog, which is the combination of the Call-ID along with two tags, one from participant in the dialog.', max_length=64)),
                ('to_uri', models.CharField(help_text='The URI of the TO header (as per INVITE)', max_length=128)),
                ('to_tag', models.CharField(help_text='The tag parameter serves as a general mechanism to identify a dialog, which is the combination of the Call-ID along with two tags, one from participant in the dialog.', max_length=64)),
                ('caller_cseq', models.CharField(help_text='Last Cseq number on the caller side.', max_length=20)),
                ('callee_cseq', models.CharField(help_text='Last Cseq number on the callee side.', max_length=20)),
                ('caller_route_set', models.CharField(blank=True, help_text='Route set on the caller side.', max_length=512, null=True)),
                ('callee_route_set', models.CharField(blank=True, help_text='Route set on the callee side.', max_length=512, null=True)),
                ('caller_contact', models.CharField(help_text="Caller's contact uri.", max_length=128)),
                ('callee_contact', models.CharField(help_text="Callee's contact uri.", max_length=128)),
                ('caller_sock', models.CharField(help_text='Local socket used to communicate with caller', max_length=64)),
                ('callee_stock', models.CharField(help_text='Local socket used to communicate with callee', max_length=64)),
                ('state', models.IntegerField(help_text='The state of the dialog.')),
                ('start_time', models.IntegerField(help_text='The timestamp (unix time) when the dialog was confirmed.')),
                ('timeout', models.IntegerField(help_text='The timestamp (unix time) when the dialog will expire.')),
                ('sflags', models.IntegerField(help_text='The flags to set for dialog and accesible from config file.')),
                ('iflags', models.IntegerField(help_text='The internal flags for dialog.')),
                ('toroute_name', models.CharField(blank=True, help_text='The name of route to be executed at dialog timeout.', max_length=32, null=True)),
                ('req_uri', models.CharField(help_text='The URI of initial request in dialog', max_length=128)),
                ('xdata', models.CharField(blank=True, help_text='Extra data associated to the dialog (e.g., serialized profiles).', max_length=512, null=True)),
            ],
            options={
                'ordering': ('-pk',),
                'db_table': 'dialog',
                'verbose_name': 'SIP dialog',
            },
        ),
        migrations.CreateModel(
            name='DialogVar',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('hash_entry', models.IntegerField(help_text='Number of the hash entry in the dialog hash table')),
                ('hash_id', models.IntegerField(help_text='The ID on the hash entry')),
                ('dialog_key', models.CharField(help_text='The key of the dialog variable', max_length=128)),
                ('dialog_value', models.CharField(help_text='The value of the dialog variable', max_length=512)),
            ],
            options={
                'ordering': ('-pk',),
                'db_table': 'dialog_vars',
                'verbose_name': 'SIP dialog vars',
            },
        ),
        migrations.AddIndex(
            model_name='dialogvar',
            index=models.Index(fields=[b'hash_entry', b'hash_id'], name='dialog_vars_hash_en_c42e1f_idx'),
        ),
        migrations.AddIndex(
            model_name='dialog',
            index=models.Index(fields=[b'hash_entry', b'hash_id'], name='dialog_hash_en_c7de57_idx'),
        ),
    ]
