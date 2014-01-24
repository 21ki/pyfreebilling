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
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with pyfreebilling. If not, see <http://www.gnu.org/licenses/>
# The Original Code is - WikiPBX web GUI front-end for FreeSWITCH
#
# The Initial Developer of the Original Code is
# Traun Leyden <tleyden@branchcut.com>
# Portions created by the Initial Developer are Copyright (C)
# the Initial Developer. All Rights Reserved.
#
# Modified by Mathias WOLFF

import ESL
from switch import logger
from switch.models import *
from pyfreebill.models import SipProfile


def get_fs_connections():
    """
    Get all available ESL connections.
    """
    logger.info("get_fs_connections()")
    voipswitchs = VoipSwitch.objects.all()
    if voipswitchs:
        logger.info("%s voipswitch's config" % len(voipswitchs))
    else:
        logger.error("""No voip switch config found! Unable
            to connect to freeswitch.""")

    for vs in voipswitchs:
        logger.info("creating ESL connection : %s / %s / %s" % (str(vs.esl_listen_ip), vs.esl_listen_port, vs.esl_password))
        yield ESL.ESLconnection(str(vs.esl_listen_ip),
                                str(vs.esl_listen_port),
                                str(vs.esl_password))

    logger.info("get_fs_connections() done")


def fs_cmd(command):
    """
    Operations via ESL.
    """
    logger.info("fs_cmd: " + command)

    for connection in get_fs_connections():
        logger.info("connection : %s" % connection)
        if not connection.connected():
            raise IOError("No connection to FreeSWITCH")
        try:
            connection.sendRecv(command.encode('utf-8'))
        except Exception, e:
            logger.info("fs_cmd error: " + str(e))
            raise
        logger.info("fs_cmd done")
        return
    raise ValueError("""No EventSocket configured in FreeSwitch.
        Cannot connect to FreeSWITCH over event socket""")


def getReloadACL():
    """Reload ACL"""
    fs_cmd("bgapi reloadacl")


def getReloadDialplan():
    """Reloadxml"""
    fs_cmd("bgapi reloadxml reloadacl")


def getReloadGateway():
    """Reload sofia's gateway"""
    logger.info("getRelaodGateway")
    logger.info("get sofia profile")
    sofia_profiles = SipProfile.objects.all()
    if sofia_profiles:
        logger.info("%s sofia profiles" % len(sofia_profiles))
    else:
        logger.error("No sofia profile found! Unable to reload.")

    for sp in sofia_profiles:
        logger.info("Reload sofia profile : %s" % sp.name)
        fs_cmd("bgapi sofia profile " + sp.name + " rescan reloadxml")
    logger.info("getReloadGateway() done")


def getRestartSofia(profile_name):
    """Restart sofia profile"""
    fs_cmd("bgapi sofia profile " + profile_name + " restart")
