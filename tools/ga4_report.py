#!/usr/bin/env python3
"""Puxa o painel de saude do O meu Salmo do GA4.

Uso: python3 tools/ga4_report.py [dias]

Credencial: ~/keystores/ga4-analytics-leitor.json (fora do repo, fora do Dropbox).
Conta de servico analytics-leitor@o-meu-salmo.iam.gserviceaccount.com, papel
Leitor na propriedade 540385741.
"""
import os, sys, json, requests
from google.oauth2 import service_account
import google.auth.transport.requests as tr

PROP = '540385741'
KEY = os.path.expanduser('~/keystores/ga4-analytics-leitor.json')
DIAS = sys.argv[1] if len(sys.argv) > 1 else '28'

c = service_account.Credentials.from_service_account_file(
    KEY, scopes=['https://www.googleapis.com/auth/analytics.readonly'])
c.refresh(tr.Request())
H = {'Authorization': 'Bearer ' + c.token}
URL = f'https://analyticsdata.googleapis.com/v1beta/properties/{PROP}:runReport'


def rep(dims, mets, start=f'{DIAS}daysAgo', end='today', limit=50, desc=None):
    body = {'dimensions': [{'name': d} for d in dims],
            'metrics': [{'name': m} for m in mets],
            'dateRanges': [{'startDate': start, 'endDate': end}],
            'limit': limit}
    if desc:
        body['orderBys'] = [{'metric': {'metricName': desc}, 'desc': True}]
    r = requests.post(URL, headers=H, json=body)
    if r.status_code != 200:
        print('ERRO', r.status_code, json.dumps(r.json())[:300])
        return []
    return [[v['value'] for v in row.get('dimensionValues', [])] +
            [v['value'] for v in row.get('metricValues', [])]
            for row in r.json().get('rows', [])]


def show(titulo, cols, rows):
    print(f'\n## {titulo}')
    print(' | '.join(cols))
    print('-|-'.join('-' * len(c) for c in cols))
    for r in rows:
        print(' | '.join(r))


def coorte(inicio, fim, dias=7):
    body = {'dimensions': [{'name': 'cohortNthDay'}],
            'metrics': [{'name': 'cohortActiveUsers'}, {'name': 'cohortTotalUsers'}],
            'cohortSpec': {
                'cohorts': [{'name': 'c', 'dimension': 'firstSessionDate',
                             'dateRange': {'startDate': inicio, 'endDate': fim}}],
                'cohortsRange': {'granularity': 'DAILY', 'startOffset': 0,
                                 'endOffset': dias}}}
    r = requests.post(URL, headers=H, json=body)
    if r.status_code != 200:
        return []
    out = []
    for row in r.json().get('rows', []):
        d = int(row['dimensionValues'][0]['value'])
        a, t = (int(v['value']) for v in row['metricValues'])
        out.append([f'D{d}', str(a), str(t), f'{100 * a / t:.0f}%' if t else '-'])
    return sorted(out, key=lambda x: int(x[0][1:]))


print(f'# O meu Salmo · GA4 · ultimos {DIAS} dias')
show('Resumo', ['ativos', 'novos', 'sessoes', 'telas', 'seg engajados'],
     rep([], ['activeUsers', 'newUsers', 'sessions', 'screenPageViews',
              'userEngagementDuration']))
show('Por dia', ['data', 'ativos', 'novos', 'sessoes'],
     rep(['date'], ['activeUsers', 'newUsers', 'sessions'], limit=90))
show('Retencao (coorte)', ['dia', 'ativos', 'coorte', '%'],
     coorte('2026-08-13', 'today'))
show('Eventos', ['evento', 'contagem', 'usuarios'],
     rep(['eventName'], ['eventCount', 'activeUsers'], limit=60, desc='eventCount'))
show('Versao', ['versao', 'ativos', 'novos'],
     rep(['appVersion'], ['activeUsers', 'newUsers'], limit=15, desc='activeUsers'))
show('Site: paginas', ['pagina', 'views', 'usuarios'],
     rep(['pagePath'], ['screenPageViews', 'activeUsers'], limit=30,
         desc='screenPageViews'))
show('Origem', ['origem', 'meio', 'sessoes'],
     rep(['sessionSource', 'sessionMedium'], ['sessions'], limit=15,
         desc='sessions'))
