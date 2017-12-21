#############
# OpenStack #
#############

[composite:osapi_share]
use = call:manila.api:root_app_factory
/: apiversions
/v1: openstack_share_api
/v2: openstack_share_api_v2

[composite:openstack_share_api]
use = call:manila.api.middleware.auth:pipeline_factory
noauth = cors faultwrap http_proxy_to_wsgi sizelimit noauth api
keystone = cors faultwrap http_proxy_to_wsgi sizelimit authtoken keystonecontext api
keystone_nolimit = cors faultwrap http_proxy_to_wsgi sizelimit authtoken keystonecontext api

[composite:openstack_share_api_v2]
use = call:manila.api.middleware.auth:pipeline_factory
noauth = cors faultwrap http_proxy_to_wsgi sizelimit noauth apiv2
keystone = cors faultwrap http_proxy_to_wsgi sizelimit authtoken keystonecontext apiv2
keystone_nolimit = cors faultwrap http_proxy_to_wsgi sizelimit authtoken keystonecontext apiv2

[filter:faultwrap]
paste.filter_factory = manila.api.middleware.fault:FaultWrapper.factory

[filter:noauth]
paste.filter_factory = manila.api.middleware.auth:NoAuthMiddleware.factory

[filter:sizelimit]
paste.filter_factory = oslo_middleware.sizelimit:RequestBodySizeLimiter.factory

[filter:http_proxy_to_wsgi]
paste.filter_factory = oslo_middleware.http_proxy_to_wsgi:HTTPProxyToWSGI.factory

[app:api]
paste.app_factory = manila.api.v1.router:APIRouter.factory

[app:apiv2]
paste.app_factory = manila.api.v2.router:APIRouter.factory

[pipeline:apiversions]
pipeline = cors faultwrap http_proxy_to_wsgi osshareversionapp

[app:osshareversionapp]
paste.app_factory = manila.api.versions:VersionsRouter.factory

##########
# Shared #
##########

[filter:keystonecontext]
paste.filter_factory = manila.api.middleware.auth:ManilaKeystoneContext.factory

[filter:authtoken]
paste.filter_factory = keystonemiddleware.auth_token:filter_factory

[filter:cors]
paste.filter_factory = oslo_middleware.cors:filter_factory
oslo_config_project = manila

