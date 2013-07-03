from django.core.management.base import BaseCommand, CommandError
from pyfreebill.models import CDR, DimDate, DimCustomerHangupcause, DimCustomerSipHangupcause, DimProviderHangupcause, DimProviderSipHangupcause, DimCustomerDestination, DimProviderDestination
import datetime
from django.db.models import Sum, Avg, Count, Max, Min
from django.db import connection
from pprint import pprint
#import dse
import math
import decimal

class Command(BaseCommand):
    args = '<date>'
    help = 'calculate stats - lastday, for last day stats - live, for live stats - custom + options for specific stats - first = [2013, 06, 14, 00, 00, 00], last = [2013, 06, 18, 00, 00, 00] '

    def handle(self, *args, **options):
        for var in args:
            try:

# date filter
# today = datetime.datetime(2013, 06, 14, 00, 00, 00)
                if var == "lastday":
                    dt = datetime.datetime.today()
                    today = datetime.datetime(dt.year, dt.month, dt.day, 00, 00, 00)
                    yesterday = today - datetime.timedelta(days=1)
                elif var == "live":
                    dt = datetime.datetime.today()
                    today = datetime.datetime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second)
                    yesterday = datetime.datetime(dt.year, dt.month, dt.day, 00, 00, 00)
                elif var == "custom":
                    for fd in first:
                        try:
                            today = datetime.datetime(fd[0], fd[1], fd[2], fd[3], fd[4], fd[5])
                        except:
                            return
                    for ld in last:
                        try:
                            yesterday = datetime.datetime(fd[0], fd[1], fd[2], fd[3], fd[4], fd[5])
                        except:
                            return
                else:
                    return
# Query construction
                qs = CDR.objects.all().filter(start_stamp__gte=yesterday).filter(start_stamp__lt=today)
                qs_uuid_unique = qs.order_by('-start_stamp')
# Customer filter - take unique uuid with late start_stamp
# DimCustomerHangupCause
                qss_hangup_unique_customer = qs_uuid_unique.values('customer','sell_destination','hangup_cause').annotate(total_calls=Count('uuid', distinct = True)).order_by('customer','sell_destination')
# DimCustomerSipHangupCause
                qss_siphangup_unique_customer = qs_uuid_unique.values('customer','sell_destination','sip_hangup_cause').annotate(total_calls=Count('uuid', distinct = True)).order_by('customer','sell_destination')
# Provider filter - take unique uuid with late start_stamp
# DimProviderHangupCause
                qss_hangup_unique_provider = qs_uuid_unique.values('lcr_carrier_id','cost_destination','hangup_cause').exclude(lcr_carrier_id__isnull=True).annotate(total_calls=Count('uuid', distinct = True)).order_by('lcr_carrier_id','cost_destination')
# DimProviderSipHangupCause
                qss_siphangup_unique_provider = qs_uuid_unique.values('lcr_carrier_id','cost_destination','sip_hangup_cause').exclude(lcr_carrier_id__isnull=True).annotate(total_calls=Count('uuid', distinct = True)).order_by('lcr_carrier_id','cost_destination')
# Stats on successful calls 
                qss2 = qs.filter(effective_duration__gt="0")
# Customers
# DimCustomerDestination
                qss_success_customer = qss2.extra(select={'destination': 'sell_destination'}).values('customer','destination').annotate(total_duration=Sum('effective_duration'), avg_duration=Avg('effective_duration'), max_duration=Max('effective_duration'), min_duration=Min('effective_duration'), success_calls=Count('id'), total_sell=Sum('total_sell'), total_cost=Sum('total_cost')).order_by('customer','sell_destination')
# Providers
# DimProviderDestination
                qss_success_provider = qss2.extra(select={'provider': 'lcr_carrier_id_id', 'destination': 'cost_destination'}).values('provider','destination').annotate(total_duration=Sum('effective_duration'), avg_duration=Avg('effective_duration'), max_duration=Max('effective_duration'), min_duration=Min('effective_duration'), success_calls=Count('id'), total_sell=Sum('total_sell'), total_cost=Sum('total_cost')).order_by('lcr_carrier_id','cost_destination')

                # get or set dim date
                try :
                    workingdate = DimDate.objects.get(date=yesterday)
                except DimDate.DoesNotExist:
                    workingdate = DimDate(
                        date = yesterday,
                        day = yesterday.day,
                        day_of_week = yesterday.isoweekday(),
                        hour = yesterday.hour,
                        month = yesterday.month,
                        quarter = " ",
                        year = yesterday.year
                    ) 
                    workingdate.save()
                    current_date = DimDate.objects.get(date=yesterday).id

# DimCustomerHangupCause
                    for item in qss_hangup_unique_customer:

                        data_dchc = DimCustomerHangupcause(
                            customer_id = item["customer"],
                            destination = item["sell_destination"],
                            hangupcause = item["hangup_cause"],
                            date_id = current_date,
                            total_calls = int(item["total_calls"])
                        )
                        data_dchc.save()

# DimCustomerSipHangupCause
                    for item in qss_siphangup_unique_customer:

                        data_dcshc = DimCustomerSipHangupcause(
                            customer_id = item["customer"],
                            destination = item["sell_destination"],
                            sip_hangupcause = item["sip_hangup_cause"],
                            date_id = current_date,
                            total_calls = int(item["total_calls"])
                        )
                        data_dcshc.save()

# DimProviderHangupCause
                    for item in qss_hangup_unique_provider:

                        data_dphc = DimProviderHangupcause(
                            provider_id = item["lcr_carrier_id"],
                            destination = item["cost_destination"],
                            hangupcause = item["hangup_cause"],
                            date_id = current_date,
                            total_calls = int(item["total_calls"])
                        )
                        data_dphc.save()

# DimProviderSipHangupCause
                    for item in qss_siphangup_unique_provider:

                        data_dpshc = DimProviderSipHangupcause(
                            provider_id = item["lcr_carrier_id"],
                            destination = item["cost_destination"],
                            sip_hangupcause = item["sip_hangup_cause"],
                            date_id = current_date,
                            total_calls = int(item["total_calls"])
                        )
                        data_dpshc.save()

# DimCustomerDestination
                    for item in qss_success_customer:

                        data_dcd = DimCustomerDestination(
                            customer_id=item["customer"],
                            destination=item["destination"],
                            date_id = current_date,
                            total_calls = "0",
                            success_calls = int(item["success_calls"]),
                            total_duration=item["total_duration"],
                            avg_duration=int(math.ceil(item["avg_duration"])),
                            max_duration=int(math.ceil(item["max_duration"])),
                            min_duration=int(math.ceil(item["min_duration"])),
                            total_sell=item["total_sell"],
                            total_cost=item["total_cost"]
                        )
                        data_dcd.save()

# DimProviderDestination
                    for item in qss_success_provider:
                        
                        data_dpd = DimProviderDestination(
                            provider_id=item["provider"],
                            destination=item["destination"],
                            date_id = current_date,
                            total_calls = "0",
                            success_calls = int(item["success_calls"]),
                            total_duration=item["total_duration"],
                            avg_duration=int(math.ceil(item["avg_duration"])),
                            max_duration=int(math.ceil(item["max_duration"])),
                            min_duration=int(math.ceil(item["min_duration"])),
                            total_sell=item["total_sell"],
                            total_cost=item["total_cost"]
                        )
                        data_dpd.save()

#                pprint(connection.queries)   
            except CDR.DoesNotExist:
                raise CommandError('stats does not exist')

            self.stdout.write('Successfully stats ')
