/*
 * Copyright (C) 2013 Lucien XU <sfietkonstantin@free.fr>
 *
 * You may use this file under the terms of the BSD license as follows:
 *
 * "Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 * * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 * * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in
 * the documentation and/or other materials provided with the
 * distribution.
 * * The names of its contributors may not be used to endorse or promote 
 * products derived from this software without specific prior written 
 * permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
 */ 

#include "twitterparser.h"

#include <QtCore/QVariant>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkReply>
#include <QtNetwork/QNetworkRequest>
#include "qjson/include/QJson/Parser"
#include <QtCore/QDebug>

TwitterParser::TwitterParser(QObject *parent) :
    QObject(parent)
{
    m_error = false;
    m_nam = new QNetworkAccessManager(this);
    m_hashTag = JollaCountdown;
    m_reply = 0;
    m_currentTweet = 0;
}

bool TwitterParser::isError() const
{
    return m_error;
}

bool TwitterParser::hasNext() const
{
    return !m_tweets.isEmpty();
}

Tweet * TwitterParser::currentTweet() const
{
    return m_currentTweet;
}

void TwitterParser::load()
{
    if (m_error) {
        return;
    }

    QString hashTag;
    switch (m_hashTag) {
    case JollaCountdown:
        hashTag = "JollaCountdown";
        break;
    case JollaLoveDay:
        hashTag = "JollaLoveDay";
        break;
    default:
        hashTag = "Jolla";
        break;
    }

    QString url = QString("http://search.twitter.com/search.json?q=%23%1").arg(hashTag);

    m_reply = m_nam->get(QNetworkRequest(QUrl(url)));
    connect(m_reply, SIGNAL(finished()), this, SLOT(slotFinished()));
}

void TwitterParser::next()
{
    if (m_error) {
        return;
    }

    if (m_currentTweet) {
        m_currentTweet->deleteLater();
    }

    if (m_tweets.isEmpty()) {
        m_currentTweet = 0;
    } else {
        m_currentTweet = m_tweets.takeFirst();
    }

    emit currentTweetChanged();
}

void TwitterParser::slotFinished()
{
    if (!m_tweets.isEmpty()) {
        qDeleteAll(m_tweets);
        m_tweets.clear();
        if (m_currentTweet) {
            m_currentTweet->deleteLater();
            m_currentTweet = 0;
            emit currentTweetChanged();
        }
    }

    if (m_reply->error() != QNetworkReply::NoError) {
        m_error = true;
        emit errorChanged();
        return;
    }

    QByteArray rawData = m_reply->readAll();
    QJson::Parser parser;
    QVariant data = parser.parse(rawData);
    QVariantList results = data.toMap().value("results").toList();


    foreach (QVariant entry, results) {
        QString name = entry.toMap().value("from_user_name").toString();
        QString nickname = entry.toMap().value("from_user").toString();
        QString avatar = entry.toMap().value("profile_image_url_https").toString();
        QString message = entry.toMap().value("text").toString();

        m_tweets.append(Tweet::create(name, nickname, avatar, message, this));
    }

    HashTag newHashtag = JollaCountdown;
    switch (m_hashTag) {
    case JollaCountdown:
        newHashtag = JollaLoveDay;
        break;
    case JollaLoveDay:
        newHashtag = Jolla;
        break;
    default:
        break;
    }
    m_hashTag = newHashtag;
    next();
}
